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

-- =====================================
-- PACIENTES
-- =====================================
INSERT INTO PACIENTE (dni, nombre, apellidos, fecha_nacimiento, email, direccion) VALUES
('11111111A', 'Laura', 'Gómez Martín', '1998-04-22', 'laura@gmail.com', 'Avenida Principal 45'),
('22222222B', 'Carlos', 'Cliente Paciente', '1990-05-20', 'carlos@mail.com', 'Calle Falsa 123'),
('33333333C', 'Marta', 'López Ruiz', '1985-11-12', 'marta@gmail.com', 'Calle Real 12')
ON CONFLICT (dni) DO NOTHING;

-- TELÉFONOS PACIENTES
INSERT INTO TELEFONO_PACIENTE (dni_paciente, telefono) VALUES
('11111111A','600111111'),
('22222222B','600222222'),
('33333333C','600333333')
ON CONFLICT (dni_paciente, telefono) DO NOTHING;

-- SALAS
INSERT INTO SALA (id_sala, nombre, tipo_sala, planta) VALUES
(1,'Sala 1','Cirugía',0),
(2,'Sala 2','Revisión',0),
(3,'Sala 3','Odontología',1)
ON CONFLICT (id_sala) DO NOTHING;

-- MATERIALES
INSERT INTO MATERIAL (cod_material, nombre, descripcion, stock_minimo) VALUES
('MAT-01','Guantes','Guantes estériles',10),
('MAT-02','Anestesia','Anestesia local',5),
('MAT-03','Mascarilla','Mascarilla quirúrgica',10)
ON CONFLICT (cod_material) DO NOTHING;

-- TRATAMIENTOS
INSERT INTO TRATAMIENTO (id_tratamiento, nombre, duracion_estimada) VALUES
(1,'Limpieza dental',30),
(2,'Extracción muela',60),
(3,'Revisión general',20)
ON CONFLICT (id_tratamiento) DO NOTHING;

-- PROFESIONALES
INSERT INTO PROFESIONAL (dni,nombre,apellidos,email,fecha_contratacion,salario,tipo_profesional) VALUES
('44444444D','Ana','Dentista Pérez','ana@mail.com',CURRENT_DATE,2000,'Dentista'),
('55555555E','Luis','Higienista López','luis@mail.com',CURRENT_DATE,1500,'Higienista')
ON CONFLICT (dni) DO NOTHING;

-- DENTISTA
INSERT INTO DENTISTA (dni,num_colegiado,especialidad) VALUES
('44444444D','D-123','Cirugía')
ON CONFLICT (dni) DO NOTHING;

-- HIGIENISTA
INSERT INTO HIGIENISTA (dni,num_titulo_formacion) VALUES
('55555555E','H-456')
ON CONFLICT (dni) DO NOTHING;

-- =====================================
-- INTERVENCIONES
-- =====================================
INSERT INTO INTERVENCION (id_intervencion,nombre,tipo_intervencion,dni_profesional,dni_paciente,id_sala,fecha_hora) VALUES
(1,'Limpieza inicial','Revisión','55555555E','11111111A',2,CURRENT_TIMESTAMP - INTERVAL '5 days'),
(2,'Extracción muela','Cirugía','44444444D','22222222B',1,CURRENT_TIMESTAMP - INTERVAL '3 days'),
(3,'Revisión anual','Revisión','55555555E','11111111A',2,CURRENT_TIMESTAMP - INTERVAL '1 day'),
(4,'Limpieza preventiva','Revisión','55555555E','33333333C',2,CURRENT_TIMESTAMP + INTERVAL '1 day'),
(5,'Empaste molar','Tratamiento','44444444D','11111111A',1,CURRENT_TIMESTAMP + INTERVAL '2 day')
ON CONFLICT (id_intervencion) DO NOTHING;

-- TRATAMIENTO_INTERVENCION
INSERT INTO TRATAMIENTO_INTERVENCION (id_tratamiento,id_intervencion) VALUES
(1,1),
(2,2),
(3,3),
(1,4),
(2,5)
ON CONFLICT (id_tratamiento,id_intervencion) DO NOTHING;

-- TRATAMIENTO_INTERVENCION_MATERIAL
INSERT INTO TRATAMIENTO_INTERVENCION_MATERIAL (id_tratamiento,id_intervencion,cod_material,cantidad_material) VALUES
(1,1,'MAT-01',2),
(2,2,'MAT-01',2),
(2,2,'MAT-02',1),
(3,3,'MAT-03',1),
(1,4,'MAT-01',1),
(2,5,'MAT-02',1)
ON CONFLICT (id_tratamiento,id_intervencion,cod_material) DO NOTHING;

-- CITAS FUTURAS (para agenda)
INSERT INTO CITA (dni_paciente,fecha_hora,motivo,estado) VALUES
('11111111A',CURRENT_TIMESTAMP + INTERVAL '3 hour','Revisión general','Pendiente'),
('22222222B',CURRENT_TIMESTAMP + INTERVAL '1 day','Extracción','Pendiente'),
('33333333C',CURRENT_TIMESTAMP + INTERVAL '2 day','Limpieza','Pendiente')
ON CONFLICT DO NOTHING;
