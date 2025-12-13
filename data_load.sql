/* 
   SCRIPT DE CARGA DE DATOS DE EJEMPLO
   Orden de inserción: 
   1. Tablas independientes (Salas, Materiales, Tratamientos...)
   2. Personas (Profesionales, Pacientes)
   3. Detalles de Personas (Teléfonos, Especialidades, Modos de pago)
   4. Operativa (Citas, Intervenciones, Consumos)
*/

-- Limpieza previa de datos (para evitar duplicados al probar)
TRUNCATE TABLE TRATAMIENTO_INTERVENCION_MATERIAL CASCADE;
TRUNCATE TABLE TRATAMIENTO_INTERVENCION CASCADE;
TRUNCATE TABLE INTERVENCION CASCADE;
TRUNCATE TABLE CITA CASCADE;
TRUNCATE TABLE LOTE CASCADE;
TRUNCATE TABLE MATERIAL CASCADE;
TRUNCATE TABLE SALA CASCADE;
TRUNCATE TABLE DENTISTA CASCADE;
TRUNCATE TABLE HIGIENISTA CASCADE;
TRUNCATE TABLE AUXILIAR CASCADE;
TRUNCATE TABLE TELEFONO_PROFESIONAL CASCADE;
TRUNCATE TABLE PROFESIONAL CASCADE;
TRUNCATE TABLE TELEFONO_PACIENTE CASCADE;
TRUNCATE TABLE PACIENTE CASCADE;
TRUNCATE TABLE TRATAMIENTO CASCADE;


-- BLOQUE 1: INFRAESTRUCTURA Y CATÁLOGOS (Persona 2 y 3)

-- 1.1 SALAS (Persona 2)
INSERT INTO SALA (nombre, tipo_sala, planta) VALUES 
('Box 1 - General', 'Consulta', 1),
('Box 2 - Ortodoncia', 'Consulta', 1),
('Quirófano A', 'Cirugía', 2),
('Sala Rayos X', 'Rayos X', 1);

-- 1.2 MATERIALES (Persona 2 - Catálogo)
INSERT INTO MATERIAL (cod_material, nombre, descripcion, stock_minimo) VALUES 
('MAT-ANEST', 'Anestesia Lidocaína', 'Ampollas de 2ml', 50),
('MAT-GUANT', 'Guantes Látex M', 'Caja de 100 unidades', 10),
('MAT-COMP', 'Composite A2', 'Jeringa de resina', 5),
('MAT-GASA', 'Gasas Estériles', 'Paquete de 50', 20);

-- 1.3 LOTES (Persona 2 - Stock Físico)
-- Vinculamos lotes a los materiales de arriba
INSERT INTO LOTE (cod_material, fecha_caducidad, cantidad_actual, fecha_entrada) VALUES 
('MAT-ANEST', '2026-12-31', 100, '2025-01-10'), -- Lote nuevo
('MAT-ANEST', '2025-06-30', 20, '2024-05-20'),  -- Lote a punto de caducar
('MAT-GUANT', '2030-01-01', 500, '2025-02-01'),
('MAT-COMP', '2025-11-15', 10, '2025-01-15');

-- 1.4 TRATAMIENTOS (Persona 3)
INSERT INTO TRATAMIENTO (nombre, duracion_estimada) VALUES 
('Limpieza Dental', 30),
('Empaste Simple', 45),
('Endodoncia', 90),
('Extracción', 60);


-- BLOQUE 2: PERSONAL SANITARIO (Persona 2 - Jerarquía)

-- 2.1 PROFESIONALES (Padres)
-- Insertamos 3 perfiles diferentes para probar la exclusividad
INSERT INTO PROFESIONAL (dni, nombre, apellidos, email, salario, tipo_profesional) VALUES 
('11111111A', 'Juan', 'Pérez Dr.', 'juan.perez@clinica.com', 3500.00, 'Dentista'),
('22222222B', 'Ana', 'García Hig.', 'ana.garcia@clinica.com', 1800.00, 'Higienista'),
('33333333C', 'Luis', 'López Aux.', 'luis.lopez@clinica.com', 1400.00, 'Auxiliar');

-- 2.2 SUBTIPOS (Hijos - Relación 1:1)
-- Dentista
INSERT INTO DENTISTA (dni, num_colegiado, especialidad) VALUES 
('11111111A', 'COL-28001', 'Cirujano Maxilofacial');

-- Higienista
INSERT INTO HIGIENISTA (dni, num_titulo_formacion) VALUES 
('22222222B', 'FP-HIG-2020');

-- Auxiliar
INSERT INTO AUXILIAR (dni, area_asignada) VALUES 
('33333333C', 'Esterilización');

-- 2.3 TELÉFONOS PROFESIONALES (Multivaluado)
INSERT INTO TELEFONO_PROFESIONAL (dni_profesional, telefono) VALUES 
('11111111A', '600111222'), -- Móvil de Juan
('11111111A', '910000001'), -- Fijo de Juan
('22222222B', '600333444'); -- Móvil de Ana


-- BLOQUE 3: PACIENTES (Persona 1 - Necesarios para operar)

INSERT INTO PACIENTE (dni, nombre, apellidos, fecha_nacimiento, email) VALUES 
('99999999Z', 'Carlos', 'Cliente Paciente', '1990-05-20', 'carlos@mail.com'),
('88888888Y', 'Marta', 'Asegurada Paciente', '1985-11-12', 'marta@mail.com');

INSERT INTO TELEFONO_PACIENTE (dni_paciente, telefono) VALUES 
('99999999Z', '666777888');


-- BLOQUE 4: OPERATIVA DIARIA (Integración de todo el grupo)

-- 4.1 CITA (Persona 1)
INSERT INTO CITA (dni_paciente, fecha_hora, motivo, estado) VALUES 
('99999999Z', '2025-10-20 10:00:00', 'Dolor de muelas', 'Realizada');

-- 4.2 INTERVENCIÓN (Persona 3 - Relación Triple)
-- Juan (Dentista) atiende a Carlos (Paciente) en el Box 1
INSERT INTO INTERVENCION (nombre, tipo_intervencion, dni_profesional, dni_paciente, id_sala, fecha_hora) VALUES 
('Cirugía de urgencia', 'Cirugía', '11111111A', '99999999Z', 1, '2025-10-20 10:05:00');

-- Recuperamos el ID de la intervención recién creada (Asumimos que es ID 1 si es la primera)
-- En un script real usaríamos subconsultas, pero para carga manual usamos el 1.

-- 4.3 TRATAMIENTOS APLICADOS
-- En esa intervención se hizo una Extracción (ID 4)
INSERT INTO TRATAMIENTO_INTERVENCION (id_tratamiento, id_intervencion) VALUES 
(4, 1);

-- 4.4 CONSUMO DE MATERIAL (Persona 2 - ¡Tu parte clave!)
-- En la extracción se gastó: 1 de Anestesia y 2 de Guantes
INSERT INTO TRATAMIENTO_INTERVENCION_MATERIAL (id_tratamiento, id_intervencion, cod_material, cantidad_material) VALUES 
(4, 1, 'MAT-ANEST', 1),
(4, 1, 'MAT-GUANT', 2);