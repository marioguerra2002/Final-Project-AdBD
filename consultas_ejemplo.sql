/* 
   SCRIPT DE CONSULTAS DE EJEMPLO
*/


-- Ver consultas de un usuario
select * from cita c 
where c.dni_paciente = '99999999Z';

-- Ver datos de un usuario
select * from paciente p  
where p.dni = '99999999Z';

-- Ver qué empleado va a atender a una intervencion
select p.nombre from profesional p 
join intervencion i on p.dni = i.dni_profesional
where i.id_intervencion = 1;

-- Ver todos los pacientes que tienen una cita o una intervención x dia
SELECT
    p.dni,
    p.nombre,
    'CITA' AS tipo,
    c.fecha_hora
FROM paciente p
JOIN cita c
  ON c.dni_paciente = p.dni
WHERE c.fecha_hora >= TIMESTAMP '2025-10-20 00:00:00'
  AND c.fecha_hora <  TIMESTAMP '2025-10-21 00:00:00'

UNION ALL

SELECT
    p.dni,
    p.nombre,
    'INTERVENCION' AS tipo,
    i.fecha_hora
FROM paciente p
JOIN intervencion i
  ON i.dni_paciente = p.dni
WHERE i.fecha_hora >= TIMESTAMP '2025-10-20 00:00:00'
  AND i.fecha_hora <  TIMESTAMP '2025-10-21 00:00:00';

-- Ver todos los profesionales que tienen una cita o una intervención x dia, además de a qué paciente
SELECT
    pr.nombre AS profesional,
    pa.nombre AS paciente,
    'CITA'    AS tipo,
    c.fecha_hora
FROM profesional pr
JOIN observacion o
  ON o.dni_profesional = pr.dni
JOIN cita c
  ON c.id_cita = o.id_cita
JOIN paciente pa
  ON pa.dni = c.dni_paciente
WHERE c.fecha_hora >= TIMESTAMP '2025-10-20 00:00:00'
  AND c.fecha_hora <  TIMESTAMP '2025-10-21 00:00:00'

UNION ALL

SELECT
    pr.nombre AS profesional,
    pa.nombre AS paciente,
    'INTERVENCION' AS tipo,
    i.fecha_hora
FROM profesional pr
JOIN intervencion i
  ON i.dni_profesional = pr.dni
JOIN paciente pa
  ON pa.dni = i.dni_paciente
WHERE i.fecha_hora >= TIMESTAMP '2025-10-20 00:00:00'
  AND i.fecha_hora <  TIMESTAMP '2025-10-21 00:00:00';
