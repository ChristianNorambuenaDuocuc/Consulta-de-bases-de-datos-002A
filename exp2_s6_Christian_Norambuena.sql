

-- ========Caso 1 reporteria de asesorias ========
-- paso 1 , revisar las tablas--
select * from profesional
select * from asesoria
select * from empresa
select * from sector

-- paso 2--
-- consulta--
select a.id_profesional as ID,
a.appaterno || ' ' || a.apmaterno || ' ' ||  a.nombre AS PROFESIONAL,
(select COUNT (*)
from profesional a1
inner join asesoria b1
on a1.id_profesional=b1.id_profesional
inner join empresa c1
on b1.cod_empresa=c1.cod_empresa
inner join sector d1
on c1.cod_sector=d1.cod_sector
where a.id_profesional=b1.id_profesional and c1.cod_sector=3) AS "NUMERO ASESORIA BANCA",
TO_CHAR((select SUM (b2.honorario)
from profesional a2
inner join asesoria b2
on a2.id_profesional=b2.id_profesional
inner join empresa c2
on b2.cod_empresa=c2.cod_empresa
inner join sector d2
on c2.cod_sector=d2.cod_sector
where a.id_profesional=b2.id_profesional and c2.cod_sector=3),'$999G999G999') AS "MONTO TOTAL BANCA",
(select COUNT (*)
from profesional a3
inner join asesoria b3
on a3.id_profesional=b3.id_profesional
inner join empresa c3
on b3.cod_empresa=c3.cod_empresa
inner join sector d3
on c3.cod_sector=d3.cod_sector
where a.id_profesional=b3.id_profesional AND c3.cod_sector=4) AS "NUMERO ASESORIA RETAIL",
TO_CHAR((select SUM (b4.honorario)
from profesional a4
inner join asesoria b4
on a4.id_profesional=b4.id_profesional
inner join empresa c4
on b4.cod_empresa=c4.cod_empresa
inner join sector d4
on c4.cod_sector=d4.cod_sector
where a.id_profesional=b4.id_profesional AND c4.cod_sector=4),'$999G999G999') AS "MONTO TOTAL RETAIL",

(select COUNT (*)
from profesional a1
inner join asesoria b1
on a1.id_profesional=b1.id_profesional
inner join empresa c1
on b1.cod_empresa=c1.cod_empresa
inner join sector d1
on c1.cod_sector=d1.cod_sector
where a.id_profesional=b1.id_profesional and c1.cod_sector=3)
+
(select COUNT (*)
from profesional a3
inner join asesoria b3
on a3.id_profesional=b3.id_profesional
inner join empresa c3
on b3.cod_empresa=c3.cod_empresa
inner join sector d3
on c3.cod_sector=d3.cod_sector
where a.id_profesional=b3.id_profesional AND c3.cod_sector=4)
AS "TOTAL ASESORIAS",

TO_CHAR((select SUM (b2.honorario)
from profesional a2
inner join asesoria b2
on a2.id_profesional=b2.id_profesional
inner join empresa c2
on b2.cod_empresa=c2.cod_empresa
inner join sector d2
on c2.cod_sector=d2.cod_sector
where a.id_profesional=b2.id_profesional and c2.cod_sector=3)
+
(select SUM (b4.honorario)
from profesional a4
inner join asesoria b4
on a4.id_profesional=b4.id_profesional
inner join empresa c4
on b4.cod_empresa=c4.cod_empresa
inner join sector d4
on c4.cod_sector=d4.cod_sector
where a.id_profesional=b4.id_profesional AND c4.cod_sector=4),'$999G999G999') AS "TOTAL HONORARIOS"

from profesional a
WHERE a.id_profesional IN (
    SELECT b.id_profesional
    FROM asesoria b
    JOIN empresa c ON b.cod_empresa = c.cod_empresa
    WHERE c.cod_sector = 3
)
AND a.id_profesional IN (
    SELECT b.id_profesional
    FROM asesoria b
    JOIN empresa c ON b.cod_empresa = c.cod_empresa
    WHERE c.cod_sector = 4
)
order by ID asc;

-- ========Caso 2 resumen de honorarios ========
-- paso 1 , revisar las tablas--
select * from profesional
select * from asesoria
select * from profesion
select * from comuna

-- paso 2 --
-- Consulta --
CREATE TABLE REPORTE_MES AS
(select a.id_profesional as "ID_PROF",
a.appaterno || ' ' || a.apmaterno || ' ' ||  a.nombre AS "NOMBRE_COMPLETO",
INITCAP(LOWER((select b1.nombre_profesion
from profesion b1
where a.cod_profesion=b1.cod_profesion))) AS "NOMBRE_PROFESION",
INITCAP(LOWER((select b2.nom_comuna
from comuna b2
where a.cod_comuna=b2.cod_comuna)))  AS "NOM_COMUNA",
(select COUNT (*)
from profesional a3
inner join asesoria b3
on a3.id_profesional=b3.id_profesional
where a.id_profesional=b3.id_profesional AND b3.fin_asesoria BETWEEN DATE '2024-04-01' AND DATE '2024-04-30') AS "NRO_ASESORIAS",
(select SUM (b4.honorario)
from asesoria b4
where a.id_profesional=b4.id_profesional AND b4.fin_asesoria BETWEEN DATE '2024-04-01' AND DATE '2024-04-30') AS "MONTO_TOTAL_HONORARIOS",
TRUNC((select AVG (b5.honorario)
from asesoria b5
where a.id_profesional=b5.id_profesional AND b5.fin_asesoria BETWEEN DATE '2024-04-01' AND DATE '2024-04-30')) AS "PROMEDIO_HONORARIO",
(select MIN (b6.honorario)
from asesoria b6
where a.id_profesional=b6.id_profesional AND b6.fin_asesoria BETWEEN DATE '2024-04-01' AND DATE '2024-04-30') AS "HONORARIO_MINIMO",
(select MAX (b7.honorario)
from asesoria b7
where a.id_profesional=b7.id_profesional AND b7.fin_asesoria BETWEEN DATE '2024-04-01' AND DATE '2024-04-30') AS "HONORARIO_MAXIMO"

from profesional a
WHERE EXISTS (select 1
from asesoria b8
where a.id_profesional=b8.id_profesional AND b8.fin_asesoria BETWEEN DATE '2024-04-01' AND DATE '2024-04-30'))

order by ID_PROF asc;

-- ========Caso 3 Modificacion de honorarios ========
-- paso 1 , revisar las tablas--

select * from profesional
select * from asesoria


-- paso 2 --
-- Consulta ANTES DE LA MODIFICACION --
select (select SUM (b1.honorario)
from asesoria b1
WHERE a.id_profesional=b1.id_profesional AND EXTRACT(MONTH FROM b1.fin_asesoria) = 3
  AND EXTRACT(YEAR  FROM b1.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1) AS "HONORARIO",
a.id_profesional AS "ID_PROFESIONAL",
a.numrun_prof AS "NUMRUN_PROF",
a.sueldo AS SUELDO
FROM PROFESIONAL a
WHERE EXISTS (select 1
from asesoria b2
WHERE a.id_profesional=b2.id_profesional AND EXTRACT(MONTH FROM b2.fin_asesoria) = 3
  AND EXTRACT(YEAR  FROM b2.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1)
ORDER BY ID_PROFESIONAL ASC;

-- paso 3 --
-- Consulta DESPUES DE LA MODIFICACION --
select (select SUM (b1.honorario)
from asesoria b1
WHERE a.id_profesional=b1.id_profesional AND EXTRACT(MONTH FROM b1.fin_asesoria) = 3
  AND EXTRACT(YEAR  FROM b1.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1) AS "HONORARIO",
a.id_profesional AS "ID_PROFESIONAL",
a.numrun_prof AS "NUMRUN_PROF",
CASE
WHEN (select SUM (b1.honorario)
from asesoria b1
WHERE a.id_profesional=b1.id_profesional AND EXTRACT(MONTH FROM b1.fin_asesoria) = 3
  AND EXTRACT(YEAR  FROM b1.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1)<1000000 THEN a.sueldo*1.10
WHEN (select SUM (b1.honorario)
from asesoria b1
WHERE a.id_profesional=b1.id_profesional AND EXTRACT(MONTH FROM b1.fin_asesoria) = 3
  AND EXTRACT(YEAR  FROM b1.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1)>=1000000 THEN a.sueldo*1.15 END AS SUELDO
  
FROM PROFESIONAL a

WHERE EXISTS (select 1
from asesoria b2
WHERE a.id_profesional=b2.id_profesional AND EXTRACT(MONTH FROM b2.fin_asesoria) = 3
  AND EXTRACT(YEAR  FROM b2.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1)
  
ORDER BY ID_PROFESIONAL ASC;
commit;
-- PASO 4--
-- UPDATE DE LA COLUMNA SUELDO DE LA TABLA PROFESIONAL--

UPDATE PROFESIONAL a
SET a.sueldo=  

CASE
WHEN (select SUM (b1.honorario)
from asesoria b1
WHERE a.id_profesional=b1.id_profesional AND EXTRACT(MONTH FROM b1.fin_asesoria) = 3
  AND EXTRACT(YEAR  FROM b1.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1)<1000000 THEN a.sueldo*1.10
WHEN (select SUM (b1.honorario)
from asesoria b1
WHERE a.id_profesional=b1.id_profesional AND EXTRACT(MONTH FROM b1.fin_asesoria) = 3
  AND EXTRACT(YEAR  FROM b1.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1)>=1000000 THEN a.sueldo*1.15 END
  
WHERE EXISTS (select 1
from asesoria b2
WHERE a.id_profesional=b2.id_profesional AND EXTRACT(MONTH FROM b2.fin_asesoria) = 3
  AND EXTRACT(YEAR  FROM b2.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1);
  

