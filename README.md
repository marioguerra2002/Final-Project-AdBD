#  Sistema de Gestión de Clínica Dental

[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/)
[![Flask](https://img.shields.io/badge/Flask-3.0+-green.svg)](https://flask.palletsprojects.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14+-336791.svg)](https://www.postgresql.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Sistema integral de gestión para clínicas dentales desarrollado con Flask y PostgreSQL. Proporciona una API REST completa para gestionar pacientes, profesionales, citas, intervenciones, tratamientos y materiales.

##  Tabla de Contenidos

- [ Sistema de Gestión de Clínica Dental]
##  Características

- **Gestión de Pacientes**: CRUD completo de pacientes con información personal y de contacto
- **Gestión de Profesionales**: Control de dentistas, higienistas y auxiliares
- **Sistema de Citas**: Programación y seguimiento de citas
- **Intervenciones Médicas**: Registro detallado de procedimientos dentales
- **Tratamientos**: Gestión de tratamientos y su relación con intervenciones
- **Control de Materiales**: Inventario y uso de materiales en tratamientos
- **Laboratorios Externos**: Gestión de encargos a laboratorios
- **Historial Clínico**: Consulta completa del historial de pacientes
- **Agenda Profesional**: Visualización de citas e intervenciones por profesional

##  Arquitectura

El sistema está construido sobre una arquitectura de 3 capas:

1. **Capa de Presentación**: API REST desarrollada con Flask
2. **Capa de Lógica de Negocio**: Procesamiento de datos y validaciones
3. **Capa de Datos**: Base de datos PostgreSQL con esquema normalizado

### Tecnologías Utilizadas

- **Framework Web**: Flask 3.0+ - Microframework web de Python para crear la API REST
- **Lenguaje**: Python 3.8+
- **Base de Datos**: PostgreSQL 14+
- **Conector DB**: psycopg2 - Adaptador de PostgreSQL para Python
- **Arquitectura API**: RESTful
- **Diseño de Diagramas**: Draw.io - Herramienta para modelado ER y esquemas de base de datos

##  Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

- **Python 3.8 o superior** - Lenguaje de programación principal
- **venv** - Módulo de Python para crear entornos virtuales (incluido por defecto con Python 3.3+)
- **PostgreSQL 14 o superior** - Sistema de gestión de base de datos
- **pip** - Gestor de paquetes de Python para instalar Flask y dependencias
- **Draw.io** (opcional) - Solo si deseas editar los diagramas del proyecto

##  Instalación

### 1. Clonar el Repositorio

```bash
git clone https://github.com/marioguerra2002/Final-Project-AdBD.git
cd Final-Project-AdBD
```

### 2. Crear y Activar Entorno Virtual

Es recomendable usar un entorno virtual (venv) para aislar las dependencias del proyecto:

**En macOS/Linux:**
```bash
# Crear el entorno virtual
python3 -m venv venv

# Activar el entorno virtual
source venv/bin/activate
```

**En Windows:**
```bash
# Crear el entorno virtual
python -m venv venv

# Activar el entorno virtual
venv\Scripts\activate
```

Una vez activado, verás `(venv)` al inicio de tu terminal.

### 3. Instalar Dependencias

Con el entorno virtual activado, instala Flask y el conector de PostgreSQL:

```bash
pip install flask psycopg2-binary
```

Alternativamente, si hay un archivo `requirements.txt`:

```bash
pip install -r requirements.txt
```

**Paquetes principales:**
- `flask`: Framework web para crear la API REST
- `psycopg2-binary`: Conector para PostgreSQL

**Nota:** Para desactivar el entorno virtual cuando termines, simplemente ejecuta:
```bash
deactivate
```

##  Configuración de la Base de Datos

### 4. Crear la Base de Datos y Usuario

Conéctate a PostgreSQL como superusuario:

```bash
psql -U postgres
```

Ejecuta los siguientes comandos:

```sql
CREATE DATABASE clinica;
CREATE USER clinica_user WITH PASSWORD 'clinica123';
GRANT ALL PRIVILEGES ON DATABASE clinica TO clinica_user;
\c clinica
GRANT ALL ON SCHEMA public TO clinica_user;
```

### 5. Crear el Esquema

```bash
psql -U clinica_user -d clinica -f schema.sql
```

### 6. Cargar Datos de Ejemplo (Opcional)

```bash
psql -U clinica_user -d clinica -f data_load.sql
```

### 7. Configurar Conexión

Si necesitas modificar los parámetros de conexión, edita el archivo `app2.py`:

```python
def get_db_connection():
    return psycopg2.connect(
        host="localhost",
        database="clinica",
        user="clinica_user",
        password="clinica123"
    )
```

##  Uso

### Iniciar el Servidor Flask

**Importante:** Asegúrate de tener el entorno virtual activado antes de ejecutar el servidor.

```bash
# Activar el entorno virtual (si no está activado)
source venv/bin/activate  # En macOS/Linux
# o
venv\Scripts\activate     # En Windows

# Iniciar el servidor Flask
python app2.py
```

El servidor Flask se iniciará en `http://localhost:5000` en modo debug.

**Notas:**
- El servidor está configurado para escuchar en todas las interfaces de red (`0.0.0.0`) y ejecutarse en el puerto 5000
- Mantén la terminal abierta mientras uses la API
- Para detener el servidor, presiona `Ctrl+C`

### Probar la API

Puedes usar herramientas como:
- **curl**: Desde la línea de comandos
- **Postman**: Interfaz gráfica para testing de APIs
- **httpie**: Cliente HTTP de línea de comandos
- **Thunder Client**: Extensión de VS Code

Ejemplo con curl:

```bash
# Obtener información de un paciente
curl http://localhost:5000/patients/99999999Z

# Crear un nuevo paciente
curl -X POST http://localhost:5000/patients \
  -H "Content-Type: application/json" \
  -d '{
    "dni": "12345678A",
    "nombre": "Juan",
    "apellidos": "Pérez García",
    "fecha_nacimiento": "1990-05-15",
    "email": "juan.perez@email.com",
    "direccion": "Calle Principal 123"
  }'
```

##  Endpoints de la API

### Pacientes

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/patients` | Crear nuevo paciente |
| GET | `/patients/<dni>` | Obtener paciente por DNI |
| PUT | `/patients/<dni>` | Actualizar paciente |
| DELETE | `/patients/<dni>` | Eliminar paciente |
| GET | `/historial/paciente/<dni>` | Obtener historial completo del paciente |

### Profesionales

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/profesional/<dni>/intervenciones` | Obtener intervenciones de un profesional |
| GET | `/profesional/<dni>/agenda` | Obtener agenda (citas + intervenciones) |

### Intervenciones

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/operaciones/nueva_intervencion` | Crear intervención con tratamientos y materiales |
| PUT | `/intervenciones/<id>` | Actualizar intervención |
| DELETE | `/intervenciones/<id>` | Eliminar intervención |
| GET | `/intervenciones/<id>/tratamientos` | Obtener tratamientos de una intervención |
| GET | `/intervenciones/<id>/materiales` | Obtener materiales usados en una intervención |

### Ejemplo de Request: Crear Intervención

```json
POST /operaciones/nueva_intervencion
{
  "dni_profesional": "44444444D",
  "dni_paciente": "99999999Z",
  "id_sala": 1,
  "nombre_intervencion": "Endodoncia",
  "tipo": "Tratamiento de Conducto",
  "tratamientos": [1, 2],
  "materiales": [
    {"cod": "MAT-01", "cantidad": 2},
    {"cod": "MAT-02", "cantidad": 1}
  ]
}
```

##  Estructura del Proyecto

```
Final-Project-AdBD/
│
├── app2.py                      # Aplicación Flask con todos los endpoints
├── schema.sql                   # Esquema de la base de datos
├── data_load.sql               # Datos de ejemplo
├── consultas_ejemplo.sql       # Consultas SQL de ejemplo
├── README.md                   # Este archivo
├── venv/                        # Entorno virtual (no se sube a Git)
│
└── diagrams/
    ├── DiagramaER.drawio.png   # Diagrama Entidad-Relación
    └── DiagramaTablas.drawio.png # Diagrama de tablas
```

**Nota:** La carpeta `venv/` contiene el entorno virtual y no debe subirse al repositorio (añadida en `.gitignore`).

##  Diagramas

El proyecto incluye diagramas diseñados con **Draw.io** en la carpeta `diagrams/`:

- **DiagramaER.drawio.png**: Modelo Entidad-Relación completo del sistema de clínica dental
- **DiagramaTablas.drawio.png**: Esquema detallado de tablas con relaciones y atributos

### Herramienta de Diseño

Los diagramas se han creado con [Draw.io](https://app.diagrams.net/), una herramienta gratuita de diagramación que permite:
- Diseño de diagramas ER profesionales
- Exportación en múltiples formatos (PNG, SVG, PDF)
- Edición online sin instalación
- Colaboración en tiempo real

Para editar los diagramas, importa los archivos `.png` directamente en Draw.io, ya que contienen la información del diagrama embebida.

##  Consultas de Ejemplo

El archivo `consultas_ejemplo.sql` contiene consultas útiles como:

- Ver todas las citas de un paciente
- Obtener información completa de un paciente
- Ver qué profesional atenderá una intervención
- Listar todos los pacientes con cita o intervención en un día específico
- Ver la agenda diaria de profesionales

Ejemplo:

```sql
-- Ver todos los pacientes que tienen una cita o intervención en una fecha
SELECT
    p.dni,
    p.nombre,
    'CITA' AS tipo,
    c.fecha_hora
FROM paciente p
JOIN cita c ON c.dni_paciente = p.dni
WHERE c.fecha_hora >= TIMESTAMP '2025-10-20 00:00:00'
  AND c.fecha_hora < TIMESTAMP '2025-10-21 00:00:00'
UNION ALL
SELECT
    p.dni,
    p.nombre,
    'INTERVENCION' AS tipo,
    i.fecha_hora
FROM paciente p
JOIN intervencion i ON i.dni_paciente = p.dni
WHERE i.fecha_hora >= TIMESTAMP '2025-10-20 00:00:00'
  AND i.fecha_hora < TIMESTAMP '2025-10-21 00:00:00';
```

## 👥 Autores

Este proyecto ha sido desarrollado como trabajo final de la asignatura de Administración de Bases de Datos (AdBD):

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/marioguerra2002">
        <img src="https://github.com/marioguerra2002.png" width="100px;" alt="Mario Guerra Pérez"/><br>
        <sub><b>Mario Guerra Pérez</b></sub>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/alu0101540153">
        <img src="https://github.com/alu0101540153.png" width="100px;" alt="Víctor Rodríguez Dorta"/><br>
        <sub><b>Víctor Rodríguez Dorta</b></sub>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/danielmarhuenda">
        <img src="https://github.com/danielmarhuenda.png" width="100px;" alt="Daniel Marhuenda Guillen"/><br>
        <sub><b>Daniel Marhuenda Guillen</b></sub>
      </a>
    </td>
  </tr>
</table>

##  Licencia

Este proyecto es software educativo desarrollado para la asignatura de Administración de Bases de Datos.


