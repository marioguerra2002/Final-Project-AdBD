from flask import Flask, request, jsonify
import psycopg2
from psycopg2.extras import RealDictCursor # Importante para las consultas nuevas

app = Flask(__name__)

# --- TU CONFIGURACIÓN DE BASE DE DATOS (INTACTA) ---
def get_db_connection():
    return psycopg2.connect(
        host="localhost",
        database="clinica",
        user="clinica_user",
        password="clinica123"
    )

# ==========================================
# GESTIÓN DE PACIENTES (Tu código original)
# ==========================================

# CREATE patient
@app.route("/patients", methods=["POST"])
def create_patient():
    data = request.get_json()

    required_fields = [
        "dni", "nombre", "apellidos",
        "fecha_nacimiento", "email", "direccion"
    ]

    for field in required_fields:
        if field not in data:
            return jsonify({"error": f"Missing field: {field}"}), 400

    try:
        conn = get_db_connection()
        cur = conn.cursor()

        cur.execute(
            """
            INSERT INTO PACIENTE (dni, nombre, apellidos, fecha_nacimiento, email, direccion)
            VALUES (%s, %s, %s, %s, %s, %s)
            """,
            (
                data["dni"],
                data["nombre"],
                data["apellidos"],
                data["fecha_nacimiento"],
                data["email"],
                data["direccion"]
            )
        )

        conn.commit()
        cur.close()
        conn.close()

        return jsonify({
            "message": "Patient created successfully",
            "dni": data["dni"]
        }), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# READ patient by DNI
@app.route("/patients/<string:dni>", methods=["GET"])
def get_patient(dni):
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        cur.execute(
            """
            SELECT dni, nombre, apellidos, fecha_nacimiento, email, direccion
            FROM PACIENTE
            WHERE dni = %s
            """,
            (dni,)
        )

        patient = cur.fetchone()
        cur.close()
        conn.close()

        if patient is None:
            return jsonify({"error": "Patient not found"}), 404

        return jsonify({
            "dni": patient[0],
            "nombre": patient[1],
            "apellidos": patient[2],
            "fecha_nacimiento": str(patient[3]),
            "email": patient[4],
            "direccion": patient[5]
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ==========================================
# NUEVAS FUNCIONALIDADES SOLICITADAS
# ==========================================

# 1. HISTORIAL DEL PACIENTE (DNI -> Historial completo)
@app.route('/historial/paciente/<dni>', methods=['GET'])
def get_historial_paciente(dni):
    try:
        conn = get_db_connection()
        # Usamos RealDictCursor aquí para facilitar la lectura de los JOINs
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        query = """
            SELECT 
                i.fecha_hora, 
                i.nombre as intervencion, 
                t.nombre as tratamiento,
                prof.nombre as doctor_nombre, 
                prof.apellidos as doctor_apellidos
            FROM INTERVENCION i
            JOIN TRATAMIENTO_INTERVENCION ti ON i.id_intervencion = ti.id_intervencion
            JOIN TRATAMIENTO t ON ti.id_tratamiento = t.id_tratamiento
            JOIN PROFESIONAL prof ON i.dni_profesional = prof.dni
            WHERE i.dni_paciente = %s
            ORDER BY i.fecha_hora DESC
        """
        cur.execute(query, (dni,))
        historial = cur.fetchall()
        cur.close()
        conn.close()
        
        return jsonify(historial), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# 2. TODAS LAS INTERVENCIONES DE UN PROFESIONAL
@app.route('/profesional/<dni>/intervenciones', methods=['GET'])
def get_intervenciones_profesional(dni):
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        # Obtenemos intervenciones y el nombre del paciente
        query = """
            SELECT 
                i.id_intervencion,
                i.fecha_hora,
                i.nombre as intervencion,
                p.nombre as nombre_paciente, 
                p.apellidos as apellidos_paciente
            FROM INTERVENCION i
            JOIN PACIENTE p ON i.dni_paciente = p.dni
            WHERE i.dni_profesional = %s
            ORDER BY i.fecha_hora DESC
        """
        cur.execute(query, (dni,))
        intervenciones = cur.fetchall()
        cur.close()
        conn.close()
        return jsonify(intervenciones), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# 3. AGENDA DEL PROFESIONAL (Pacientes con los que tiene cita futura)
@app.route('/profesional/<dni>/agenda', methods=['GET'])
def get_agenda_profesional(dni):
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        # Filtramos por fecha futura (CURRENT_TIMESTAMP)
        query = """
            SELECT 
                i.fecha_hora,
                p.dni as dni_paciente,
                p.nombre,
                p.apellidos,
                i.nombre as intervencion_programada,
                s.nombre as sala
            FROM INTERVENCION i
            JOIN PACIENTE p ON i.dni_paciente = p.dni
            JOIN SALA s ON i.id_sala = s.id_sala
            WHERE i.dni_profesional = %s 
              AND i.fecha_hora >= CURRENT_TIMESTAMP
            ORDER BY i.fecha_hora ASC
        """
        cur.execute(query, (dni,))
        agenda = cur.fetchall()
        cur.close()
        conn.close()
        return jsonify(agenda), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# 4. AÑADIR NUEVA INTERVENCIÓN COMPLETA (Intervención + Tratamientos + Materiales)
@app.route('/operaciones/nueva_intervencion', methods=['POST'])
def crear_intervencion_completa():
    data = request.get_json()
    
    # Validamos campos básicos
    required = ["dni_profesional", "dni_paciente", "id_sala", "nombre_intervencion", "tratamientos"]
    for field in required:
        if field not in data:
            return jsonify({"error": f"Falta campo requerido: {field}"}), 400

    conn = get_db_connection()
    try:
        cur = conn.cursor()
        
        # PASO A: Crear la Intervención en la tabla INTERVENCION
        # Se asume 'tipo' por defecto si no viene
        tipo = data.get('tipo', 'General') 
        
        cur.execute("""
            INSERT INTO INTERVENCION (nombre, tipo_intervencion, dni_profesional, dni_paciente, id_sala)
            VALUES (%s, %s, %s, %s, %s)
            RETURNING id_intervencion
        """, (data['nombre_intervencion'], tipo, data['dni_profesional'], data['dni_paciente'], data['id_sala']))
        
        # Obtenemos el ID generado automáticamente
        id_intervencion = cur.fetchone()[0]
        
        # PASO B: Recorrer lista de tratamientos y guardarlos
        # data['tratamientos'] debe ser una lista de IDs, ej: [1, 3]
        for id_trat in data['tratamientos']:
            cur.execute("""
                INSERT INTO TRATAMIENTO_INTERVENCION (id_tratamiento, id_intervencion)
                VALUES (%s, %s)
            """, (id_trat, id_intervencion))
            
            # PASO C: Añadir materiales para este tratamiento (si existen en el JSON)
            # data['materiales'] debe ser lista de dicts: [{"cod": "MAT-01", "cantidad": 2}, ...]
            if 'materiales' in data:
                for mat in data['materiales']:
                    cur.execute("""
                        INSERT INTO TRATAMIENTO_INTERVENCION_MATERIAL 
                        (id_tratamiento, id_intervencion, cod_material, cantidad_material)
                        VALUES (%s, %s, %s, %s)
                    """, (id_trat, id_intervencion, mat['cod'], mat['cantidad']))

        # Confirmamos la transacción completa
        conn.commit() 
        cur.close()
        conn.close()
        
        return jsonify({
            "message": "Intervención creada con éxito junto a sus tratamientos y materiales", 
            "id_intervencion": id_intervencion
        }), 201

    except Exception as e:
        if conn:
            conn.rollback() # Si algo falla, deshacemos todo para no dejar datos a medias
        return jsonify({"error": str(e)}), 500
# UPDATE patient
@app.route("/patients/<string:dni>", methods=["PUT"])
def update_patient(dni):
    data = request.get_json()

    fields = ["nombre", "apellidos", "fecha_nacimiento", "email", "direccion"]
    updates = {field: data[field] for field in fields if field in data}

    if not updates:
        return jsonify({"error": "No fields to update"}), 400

    set_clause = ", ".join(f"{key} = %s" for key in updates.keys())
    values = list(updates.values())
    values.append(dni)  # Para el WHERE

    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(f"""
            UPDATE PACIENTE
            SET {set_clause}
            WHERE dni = %s
        """, values)
        if cur.rowcount == 0:
            return jsonify({"error": "Patient not found"}), 404
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"message": "Patient updated successfully", "dni": dni}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# DELETE patient
@app.route("/patients/<string:dni>", methods=["DELETE"])
def delete_patient(dni):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("DELETE FROM PACIENTE WHERE dni = %s", (dni,))
        if cur.rowcount == 0:
            return jsonify({"error": "Patient not found"}), 404
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"message": "Patient deleted successfully", "dni": dni}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
# UPDATE intervención
@app.route("/intervenciones/<int:id_intervencion>", methods=["PUT"])
def update_intervencion(id_intervencion):
    data = request.get_json()
    
    fields = ["nombre", "tipo_intervencion", "dni_profesional", "dni_paciente", "id_sala", "fecha_hora"]
    updates = {field: data[field] for field in fields if field in data}

    if not updates:
        return jsonify({"error": "No fields to update"}), 400

    set_clause = ", ".join(f"{key} = %s" for key in updates.keys())
    values = list(updates.values())
    values.append(id_intervencion)

    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(f"""
            UPDATE INTERVENCION
            SET {set_clause}
            WHERE id_intervencion = %s
        """, values)
        if cur.rowcount == 0:
            return jsonify({"error": "Intervención not found"}), 404
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"message": "Intervención updated successfully", "id_intervencion": id_intervencion}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
# DELETE intervención
@app.route("/intervenciones/<int:id_intervencion>", methods=["DELETE"])
def delete_intervencion(id_intervencion):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("DELETE FROM INTERVENCION WHERE id_intervencion = %s", (id_intervencion,))
        if cur.rowcount == 0:
            return jsonify({"error": "Intervención not found"}), 404
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"message": "Intervención deleted successfully", "id_intervencion": id_intervencion}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ==========================================
# RELACIONES N:M
# ==========================================

# GET: tratamientos de una intervención
@app.route('/intervenciones/<int:id_intervencion>/tratamientos', methods=['GET'])
def get_tratamientos_intervencion(id_intervencion):
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        query = """
            SELECT t.id_tratamiento, t.nombre, t.duracion_estimada
            FROM TRATAMIENTO t
            JOIN TRATAMIENTO_INTERVENCION ti ON t.id_tratamiento = ti.id_tratamiento
            WHERE ti.id_intervencion = %s
        """
        cur.execute(query, (id_intervencion,))
        tratamientos = cur.fetchall()
        cur.close()
        conn.close()
        return jsonify(tratamientos), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# GET: materiales asociados a una intervención
@app.route('/intervenciones/<int:id_intervencion>/materiales', methods=['GET'])
def get_materiales_intervencion(id_intervencion):
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        query = """
            SELECT tim.cod_material, m.nombre, tim.cantidad_material
            FROM TRATAMIENTO_INTERVENCION_MATERIAL tim
            JOIN MATERIAL m ON tim.cod_material = m.cod_material
            WHERE tim.id_intervencion = %s
        """
        cur.execute(query, (id_intervencion,))
        materiales = cur.fetchall()
        cur.close()
        conn.close()
        return jsonify(materiales), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)