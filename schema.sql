DROP TABLE IF EXISTS TRATAMIENTO_INTERVENCION_MATERIAL CASCADE;
DROP TABLE IF EXISTS TRATAMIENTO_INTERVENCION CASCADE;
DROP TABLE IF EXISTS TRATAMIENTO_ENCARGO CASCADE;
DROP TABLE IF EXISTS ENCARGO CASCADE;
DROP TABLE IF EXISTS LABORATORIO_EXTERNO CASCADE;
DROP TABLE IF EXISTS TRATAMIENTO CASCADE;
DROP TABLE IF EXISTS INTERVENCION CASCADE;
DROP TABLE IF EXISTS LOTE CASCADE;
DROP TABLE IF EXISTS MATERIAL CASCADE;
DROP TABLE IF EXISTS SALA CASCADE;
DROP TABLE IF EXISTS OBSERVACION CASCADE;
DROP TABLE IF EXISTS CITA CASCADE;
DROP TABLE IF EXISTS MODO_ASEGURADORA CASCADE;
DROP TABLE IF EXISTS MODO_PRIVADO CASCADE;
DROP TABLE IF EXISTS COMPANIA_ASEGURADORA CASCADE;
DROP TABLE IF EXISTS TELEFONO_PACIENTE CASCADE;
DROP TABLE IF EXISTS PACIENTE CASCADE;
DROP TABLE IF EXISTS AUXILIAR CASCADE;
DROP TABLE IF EXISTS HIGIENISTA CASCADE;
DROP TABLE IF EXISTS DENTISTA CASCADE;
DROP TABLE IF EXISTS TELEFONO_PROFESIONAL CASCADE;
DROP TABLE IF EXISTS PROFESIONAL CASCADE;

-- Esto es para que no de error al intentar crear las tablas si ya existen

-- Area 1: pacientes y administracion 

-- Entidad Principal: PACIENTE
CREATE TABLE PACIENTE (
    dni VARCHAR(9) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    email VARCHAR(100),
    direccion VARCHAR(200)
);

-- Multivaluado: TELÉFONOS DE PACIENTE
CREATE TABLE TELEFONO_PACIENTE (
    dni_paciente VARCHAR(9) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    PRIMARY KEY (dni_paciente, telefono),
    FOREIGN KEY (dni_paciente) REFERENCES PACIENTE(dni) ON DELETE CASCADE
);

-- Entidad: COMPAÑÍA ASEGURADORA
CREATE TABLE COMPANIA_ASEGURADORA (
    id_compania SERIAL PRIMARY KEY,
    nombre_compania VARCHAR(100) NOT NULL,
    telefono_contacto VARCHAR(15)
);

-- Modalidad de Pago: PRIVADO (Exclusiva 1)
CREATE TABLE MODO_PRIVADO (
    id_mprivada SERIAL PRIMARY KEY,
    dni_paciente VARCHAR(9) NOT NULL UNIQUE,
    num_cuenta VARCHAR(30) NOT NULL,
    FOREIGN KEY (dni_paciente) REFERENCES PACIENTE(dni) ON DELETE CASCADE
);

-- Modalidad de Pago: ASEGURADORA (Exclusiva 2)
CREATE TABLE MODO_ASEGURADORA (
    id_maseguradora SERIAL PRIMARY KEY,
    dni_paciente VARCHAR(9) NOT NULL UNIQUE, 
    id_compania INT NOT NULL,
    num_poliza VARCHAR(50) NOT NULL,
    FOREIGN KEY (dni_paciente) REFERENCES PACIENTE(dni) ON DELETE CASCADE,
    FOREIGN KEY (id_compania) REFERENCES COMPANIA_ASEGURADORA(id_compania) ON DELETE RESTRICT
);

-- Entidad: CITA (debil de Paciente)

CREATE TABLE CITA (
    id_cita SERIAL PRIMARY KEY,
    dni_paciente VARCHAR(9) NOT NULL,
    fecha_hora TIMESTAMP NOT NULL,
    motivo VARCHAR(100),
    estado VARCHAR(20) CHECK (estado IN ('Pendiente', 'Realizada', 'Cancelada')),
    FOREIGN KEY (dni_paciente) REFERENCES PACIENTE(dni) ON DELETE CASCADE
);

-- Area 2: profesional e infraestructura

-- Supertipo: PROFESIONAL

CREATE TABLE PROFESIONAL (
    dni VARCHAR(9) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    fecha_contratacion DATE NOT NULL DEFAULT CURRENT_DATE,
    salario DECIMAL(10, 2),
    tipo_profesional VARCHAR(20) NOT NULL,
    CONSTRAINT ck_tipo_prof CHECK (tipo_profesional IN ('Dentista', 'Higienista', 'Auxiliar'))
    -- esta condición nos ayudará a implementar la herencia ya que cada subtipo tendrá su propia tabla
);

-- Multivaluado: TELÉFONOS DE PROFESIONAL

CREATE TABLE TELEFONO_PROFESIONAL (
    dni_profesional VARCHAR(9) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    PRIMARY KEY (dni_profesional, telefono),
    FOREIGN KEY (dni_profesional) REFERENCES PROFESIONAL(dni) ON DELETE CASCADE
);

-- Subtipo: DENTISTA

CREATE TABLE DENTISTA (
    dni VARCHAR(9) PRIMARY KEY,
    num_colegiado VARCHAR(20) NOT NULL UNIQUE,
    especialidad VARCHAR(50),
    FOREIGN KEY (dni) REFERENCES PROFESIONAL(dni) ON DELETE CASCADE
);

-- Subtipo: HIGIENISTA

CREATE TABLE HIGIENISTA (
    dni VARCHAR(9) PRIMARY KEY,
    num_titulo_formacion VARCHAR(50) NOT NULL UNIQUE,
    FOREIGN KEY (dni) REFERENCES PROFESIONAL(dni) ON DELETE CASCADE
);

-- Subtipo: AUXILIAR

CREATE TABLE AUXILIAR (
    dni VARCHAR(9) PRIMARY KEY,
    area_asignada VARCHAR(50),
    FOREIGN KEY (dni) REFERENCES PROFESIONAL(dni) ON DELETE CASCADE
);

-- Entidad: OBSERVACIÓN (debil de Cita y Profesional)

CREATE TABLE OBSERVACION (
    id_observacion SERIAL PRIMARY KEY,
    id_cita INT NOT NULL,
    dni_profesional VARCHAR(9) NOT NULL,
    texto VARCHAR(1000) NOT NULL,
    fecha_hora_obs TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cita) REFERENCES CITA(id_cita) ON DELETE CASCADE,
    FOREIGN KEY (dni_profesional) REFERENCES PROFESIONAL(dni)
);

-- Entidad: SALA

CREATE TABLE SALA (
    id_sala SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    tipo_sala VARCHAR(30),
    planta INT
);

-- Entidad: MATERIAL

CREATE TABLE MATERIAL (
    cod_material VARCHAR(20) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    stock_minimo INT DEFAULT 0
);

-- Entidad: LOTE

CREATE TABLE LOTE (
    id_lote SERIAL PRIMARY KEY,
    cod_material VARCHAR(20) NOT NULL,
    fecha_caducidad DATE NOT NULL,
    cantidad_actual INT NOT NULL CHECK (cantidad_actual >= 0),
    fecha_entrada DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (cod_material) REFERENCES MATERIAL(cod_material) ON DELETE CASCADE
);

-- Area 3: intervenciones y tratamientos

-- Entidad: TRATAMIENTO

CREATE TABLE TRATAMIENTO (
    id_tratamiento SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    duracion_estimada INT NOT NULL
);

-- Entidad: INTERVENCIÓN

CREATE TABLE INTERVENCION (
    id_intervencion SERIAL PRIMARY KEY,
    nombre VARCHAR(100), -- Nombre descriptivo del acto (ej: "Cirugía matutina")
    tipo_intervencion VARCHAR(50),
    dni_profesional VARCHAR(9) NOT NULL,
    dni_paciente VARCHAR(9) NOT NULL,
    id_sala INT NOT NULL,
    fecha_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (dni_profesional) REFERENCES PROFESIONAL(dni) ON DELETE CASCADE,
    FOREIGN KEY (dni_paciente) REFERENCES PACIENTE(dni) ON DELETE CASCADE,
    FOREIGN KEY (id_sala) REFERENCES SALA(id_sala) ON DELETE CASCADE
);

-- Tabla intermedia: tratamiento - intervención (N:M)

CREATE TABLE TRATAMIENTO_INTERVENCION (
    id_tratamiento INT NOT NULL,
    id_intervencion INT NOT NULL,
    
    PRIMARY KEY (id_tratamiento, id_intervencion),
    FOREIGN KEY (id_tratamiento) REFERENCES TRATAMIENTO(id_tratamiento) ON DELETE CASCADE,
    FOREIGN KEY (id_intervencion) REFERENCES INTERVENCION(id_intervencion) ON DELETE CASCADE
);

-- Tabla intermedia: tratamiento - intervención - material (N:M)
-- Referencia a la tabla intermedia TRATAMIENTO_INTERVENCION para asegurar integridad referencial

CREATE TABLE TRATAMIENTO_INTERVENCION_MATERIAL (
    id_tratamiento INT NOT NULL,
    id_intervencion INT NOT NULL,
    cod_material VARCHAR(20) NOT NULL,
    cantidad_material INT NOT NULL CHECK (cantidad_material > 0),
    
    PRIMARY KEY (id_tratamiento, id_intervencion, cod_material),
    
    -- FK Compuesta para asegurar que referenciamos un tratamiento que realmente existe en esa intervención
    FOREIGN KEY (id_tratamiento, id_intervencion) 
        REFERENCES TRATAMIENTO_INTERVENCION(id_tratamiento, id_intervencion) 
        ON DELETE CASCADE,  -- <-- Añade la coma aquí
        
    FOREIGN KEY (cod_material) REFERENCES MATERIAL(cod_material)
);

-- Entidad: LABORATORIO EXTERNO

CREATE TABLE LABORATORIO_EXTERNO (
    id_laboratorio SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    contacto VARCHAR(50)
);

-- Entidad: ENCARGO

CREATE TABLE ENCARGO (
    id_encargo SERIAL PRIMARY KEY,
    id_laboratorio INT NOT NULL,  
    -- es int porque referencia a id_laboratorio de LABORATORIO_EXTERNO
    requerimientos VARCHAR(500),
    coste DECIMAL(10, 2),
    fecha_encargo DATE DEFAULT CURRENT_DATE,
    
    FOREIGN KEY (id_laboratorio) REFERENCES LABORATORIO_EXTERNO(id_laboratorio)
);

-- Tabla intermedia: tratamiento - encargo (N:M)

CREATE TABLE TRATAMIENTO_ENCARGO (
    id_tratamiento INT NOT NULL,
    id_encargo INT NOT NULL,
    
    PRIMARY KEY (id_tratamiento, id_encargo),
    FOREIGN KEY (id_tratamiento) REFERENCES TRATAMIENTO(id_tratamiento),
    FOREIGN KEY (id_encargo) REFERENCES ENCARGO(id_encargo)
);


-- Función que actualiza el stock de material
CREATE OR REPLACE FUNCTION actualizar_stock_material()
RETURNS TRIGGER AS $$
DECLARE
    stock_actual INT;
    lote_record RECORD;  -- <--- IMPORTANTE: debe ser RECORD
BEGIN
    -- Obtenemos la cantidad total disponible del material
    SELECT SUM(cantidad_actual) INTO stock_actual
    FROM LOTE
    WHERE cod_material = NEW.cod_material;

    -- Si no hay suficiente stock, abortamos
    IF stock_actual < NEW.cantidad_material THEN
        RAISE EXCEPTION 'No hay suficiente stock del material %', NEW.cod_material;
    END IF;

    -- Descontamos la cantidad usada de los lotes, empezando por el más antiguo
    FOR lote_record IN 
        SELECT id_lote, cantidad_actual
        FROM LOTE
        WHERE cod_material = NEW.cod_material AND cantidad_actual > 0
        ORDER BY fecha_entrada
    LOOP
        IF lote_record.cantidad_actual >= NEW.cantidad_material THEN
            UPDATE LOTE
            SET cantidad_actual = cantidad_actual - NEW.cantidad_material
            WHERE id_lote = lote_record.id_lote;
            EXIT; -- Ya descontamos todo
        ELSE
            -- Si el lote no tiene suficiente, lo vaciamos y seguimos con el siguiente
            NEW.cantidad_material := NEW.cantidad_material - lote_record.cantidad_actual;
            UPDATE LOTE
            SET cantidad_actual = 0
            WHERE id_lote = lote_record.id_lote;
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_stock
BEFORE INSERT ON TRATAMIENTO_INTERVENCION_MATERIAL
FOR EACH ROW
EXECUTE FUNCTION actualizar_stock_material();

