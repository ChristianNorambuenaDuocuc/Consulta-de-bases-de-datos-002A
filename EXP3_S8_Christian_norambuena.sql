-- USUARIO ADMINISTRADOR --
-- caso 1 --

-- LIMPIEZA --

DROP USER PRY2205_USER1 CASCADE;
DROP USER PRY2205_USER2 CASCADE;
DROP ROLE PRY2205_ROL_D;
DROP ROLE PRY2205_ROL_P;

ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;

-- CREACION DE ROLES --
CREATE ROLE PRY2205_ROL_D;
CREATE ROLE PRY2205_ROL_P;

-- PRIVILEGIOS DE ROLES --

-- Rol del due�o: puede crear objetos y conectarse
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE,
CREATE SYNONYM
TO PRY2205_ROL_D;

-- Rol limitado: usuario de consulta con permisos m�nimos
GRANT CREATE SESSION, CREATE VIEW, CREATE SYNONYM, CREATE TABLE,
CREATE SEQUENCE, CREATE TRIGGER
TO PRY2205_ROL_P;

-- creacion de usuarios --

-- Usuario due�o de los datos
CREATE USER PRY2205_USER1 IDENTIFIED BY "PRY2205_USER1"
DEFAULT TABLESPACE USERS
QUOTA UNLIMITED ON USERS;

-- Usuario generico (consulta)
CREATE USER PRY2205_USER2 IDENTIFIED BY "PRY2205_USER2"
DEFAULT TABLESPACE USERS
QUOTA 5M ON USERS;

-- asignacion de roles a los usuarios -- 
GRANT PRY2205_ROL_D TO PRY2205_USER1;
GRANT PRY2205_ROL_P TO PRY2205_USER2;

-- creacion de sinonimos --
CREATE OR REPLACE PUBLIC SYNONYM PRESTAMO FOR PRY2205_USER1.PRESTAMO;
CREATE OR REPLACE PUBLIC SYNONYM LIBRO FOR PRY2205_USER1.LIBRO;
CREATE OR REPLACE PUBLIC SYNONYM EJEMPLAR FOR PRY2205_USER1.EJEMPLAR;

-- creacion de permisos a tablas --
GRANT SELECT ON PRY2205_USER1.LIBRO TO PRY2205_ROL_P;
GRANT SELECT ON PRY2205_USER1.PRESTAMO TO PRY2205_ROL_P;
GRANT SELECT ON PRY2205_USER1.EJEMPLAR TO PRY2205_ROL_P;


-- USUARIO Usuario_prueba 2 --
-- caso 2 -- 
-- creacion de informe --

-- REVISION DE TABLAS -- 

select * FROM PRESTAMO where libroid=97148;
select * FROM LIBRO;
select * FROM EJEMPLAR where libroid=97148;


-- SEQUENCIA --
DROP SEQUENCE SEQ_CONTROL_STOCK;

CREATE SEQUENCE SEQ_CONTROL_STOCK
START WITH 1
INCREMENT BY 1
MAXVALUE 999999
NOCACHE
NOCYCLE;

-- consulta --
select                                                   
a.libroid                                                                       AS "LIBRO_ID",
b.nombre_libro                                                                  AS "NOMBRE_LIBRO",
COUNT(DISTINCT c.ejemplarid)                                                    AS "TOTAL EJEMPLARES",
(select COUNT(*) from prestamo p where p.libroid = a.libroid AND p.fecha_inicio<TRUNC(SYSDATE - INTERVAL '2' YEAR) ) AS "EN_PRESTAMO",
COUNT(DISTINCT c.ejemplarid)-  (select COUNT(*) from prestamo p where p.libroid = a.libroid AND p.fecha_inicio<TRUNC(SYSDATE - INTERVAL '2' YEAR) )   AS "DISPONIBLES",
ROUND(((select COUNT(*) from prestamo p where p.libroid = a.libroid AND p.fecha_inicio<TRUNC(SYSDATE - INTERVAL '2' YEAR))*100)/COUNT(DISTINCT c.ejemplarid),2) AS "PORCENTAJE_PRESTAMO",
CASE
WHEN COUNT(DISTINCT c.ejemplarid)-  (select COUNT(*) from prestamo p where p.libroid = a.libroid AND p.fecha_inicio<TRUNC(SYSDATE - INTERVAL '2' YEAR) )>1 THEN 'N'
WHEN COUNT(DISTINCT c.ejemplarid)-  (select COUNT(*) from prestamo p where p.libroid = a.libroid AND p.fecha_inicio<TRUNC(SYSDATE - INTERVAL '2' YEAR) )<2 THEN 'S'
END                                                                                AS "STOCK_CRITICO"
FROM PRESTAMO a
JOIN LIBRO b
ON a.libroid=b.libroid
JOIN EJEMPLAR c
ON a.libroid=c.libroid
WHERE EMPLEADOID IN(190,180,150) AND EXTRACT(YEAR FROM a.fecha_inicio) = EXTRACT(YEAR FROM SYSDATE) - 2
group by a.libroid, b.nombre_libro 
ORDER BY a.libroid ASC;

-- creacion de tabla --
DROP TABLE CONTROL_STOCK_LIBROS CASCADE CONSTRAINTS;

CREATE TABLE CONTROL_STOCK_LIBROS (
  ID_CONTROL            NUMBER,
  LIBRO_ID              NUMBER,
  NOMBRE_LIBRO          VARCHAR2(200),
  TOTAL_EJEMPLARES      NUMBER,
  EN_PRESTAMO           NUMBER,
  DISPONIBLES           NUMBER,
  PORCENTAJE_PRESTAMO   NUMBER(10,2),
  STOCK_CRITICO         CHAR(1)
);

INSERT INTO CONTROL_STOCK_LIBROS (
  ID_CONTROL, LIBRO_ID, NOMBRE_LIBRO, TOTAL_EJEMPLARES, EN_PRESTAMO, DISPONIBLES, PORCENTAJE_PRESTAMO, STOCK_CRITICO
)
SELECT
  SEQ_CONTROL_STOCK.NEXTVAL AS ID_CONTROL,
  q."LIBRO_ID"              AS LIBRO_ID,
  q."NOMBRE_LIBRO"          AS NOMBRE_LIBRO,
  q."TOTAL EJEMPLARES"      AS TOTAL_EJEMPLARES,
  q."EN_PRESTAMO"           AS EN_PRESTAMO,
  q."DISPONIBLES"           AS DISPONIBLES,
  q."PORCENTAJE_PRESTAMO"   AS PORCENTAJE_PRESTAMO,
  q."STOCK_CRITICO"         AS STOCK_CRITICO
FROM (select                                                   
a.libroid                                                                       AS "LIBRO_ID",
b.nombre_libro                                                                  AS "NOMBRE_LIBRO",
COUNT(DISTINCT c.ejemplarid)                                                    AS "TOTAL EJEMPLARES",
(select COUNT(*) from prestamo p where p.libroid = a.libroid AND p.fecha_inicio<TRUNC(SYSDATE - INTERVAL '2' YEAR) ) AS "EN_PRESTAMO",
COUNT(DISTINCT c.ejemplarid)-  (select COUNT(*) from prestamo p where p.libroid = a.libroid AND p.fecha_inicio<TRUNC(SYSDATE - INTERVAL '2' YEAR) )   AS "DISPONIBLES",
ROUND(((select COUNT(*) from prestamo p where p.libroid = a.libroid AND p.fecha_inicio<TRUNC(SYSDATE - INTERVAL '2' YEAR))*100)/COUNT(DISTINCT c.ejemplarid),2) AS "PORCENTAJE_PRESTAMO",
CASE
WHEN COUNT(DISTINCT c.ejemplarid)-  (select COUNT(*) from prestamo p where p.libroid = a.libroid AND p.fecha_inicio<TRUNC(SYSDATE - INTERVAL '2' YEAR) )>1 THEN 'N'
WHEN COUNT(DISTINCT c.ejemplarid)-  (select COUNT(*) from prestamo p where p.libroid = a.libroid AND p.fecha_inicio<TRUNC(SYSDATE - INTERVAL '2' YEAR) )<2 THEN 'S'
END                                                                                AS "STOCK_CRITICO"
FROM PRESTAMO a
JOIN LIBRO b
ON a.libroid=b.libroid
JOIN EJEMPLAR c
ON a.libroid=c.libroid
WHERE EMPLEADOID IN(190,180,150) AND EXTRACT(YEAR FROM a.fecha_inicio) = EXTRACT(YEAR FROM SYSDATE) - 2
group by a.libroid, b.nombre_libro
ORDER BY a.libroid ASC) q;

select * from CONTROL_STOCK_LIBROS;

-- USUARIO Usuario_prueba 1 --

-- CASO 3 -- 
-- CASO 3.1 --
-- TABLAS --
SELECT * FROM PRESTAMO;
SELECT * FROM LIBRO;
SELECT * FROM ALUMNO;
SELECT * FROM CARRERA;

-- CONSULTA VIEW --
DROP VIEW VW_DETALLE_MULTAS;

CREATE OR REPLACE VIEW VW_DETALLE_MULTAS AS
SELECT
a.prestamoid                                                                    AS "ID_PRESTAMO",    
INITCAP(LOWER(b.nombre)) || ' ' || INITCAP(LOWER(b.apaterno))                   AS "NOMBRE_ALUMNO",
c.descripcion                                                                   AS "NOMBRE_CARRERA", 
a.libroid                                                                       AS "ID_LIBRO",
TO_CHAR(d.precio,'$999G999G999')                                                AS "VALOR_LIBRO",
a.fecha_termino                                                                 AS "FECHA_TERMINO",
a.fecha_entrega                                                                 AS "FECHA_ENTREGA",
TRUNC(a.fecha_entrega)-TRUNC(a.fecha_termino)                                   AS "DIAS_ATRASO",
TO_CHAR(TRUNC(ROUND(d.precio*0.03*(TRUNC(a.fecha_entrega)-TRUNC(a.fecha_termino)))),'$999G999G999') AS "VALOR_MULTA",
CASE
WHEN c.carreraid=180 THEN 0.06
WHEN c.carreraid=320 THEN 0.07
WHEN c.carreraid=160 THEN 0.04
WHEN c.carreraid=220 THEN 0.02
ELSE 0
END                                                                             AS "PORCENTAJE_REBAJA_MULTA",
TO_CHAR(TRUNC(ROUND((d.precio * 0.03 * (TRUNC(a.fecha_entrega) - TRUNC(a.fecha_termino))) -
((d.precio * 0.03 * (TRUNC(a.fecha_entrega) - TRUNC(a.fecha_termino))) *
 CASE
   WHEN c.carreraid = 180 THEN 0.06
   WHEN c.carreraid = 320 THEN 0.07
   WHEN c.carreraid = 160 THEN 0.04
   WHEN c.carreraid = 220 THEN 0.02
   ELSE 0
 END))),'$999G999G999')                                                          AS "VALOR_REBAJADO"
FROM PRESTAMO a
JOIN ALUMNO b
ON a.alumnoid=b.alumnoid
JOIN CARRERA c
ON b.carreraid=c.carreraid
JOIN LIBRO d
ON a.libroid=d.libroid
WHERE TRUNC(a.fecha_entrega)>TRUNC(a.fecha_termino) AND EXTRACT(YEAR FROM a.fecha_termino) = EXTRACT(YEAR FROM SYSDATE) - 2
ORDER BY a.fecha_entrega DESC;

-- CASO 3.2 --
-- CREACION DE INDICES --
DROP INDEX IDX_FECHA_ENTREGA_TERMINO;

CREATE INDEX IDX_FECHA_ENTREGA_TERMINO
ON PRESTAMO(FECHA_ENTREGA,FECHA_TERMINO);


