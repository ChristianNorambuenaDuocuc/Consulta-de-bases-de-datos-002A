-- USUARIO ADMINISTRADOR --
SHOW USER;
-- CASO 1 --

-- LIMPIEZA --

DROP USER PRY2205_EFT CASCADE;
DROP USER PRY2205_EFT_DES CASCADE;
DROP USER PRY2205_EFT_CON CASCADE;
DROP ROLE PRY2205_ROL_D;
DROP ROLE PRY2205_ROL_C;

ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;

-- CREACION DE ROLES --
CREATE ROLE PRY2205_ROL_D;
CREATE ROLE PRY2205_ROL_C;

-- creacion de usuarios --

-- Usuario due?o de los datos
CREATE USER PRY2205_EFT IDENTIFIED BY "DiciembrE2025"
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA 10M ON USERS;

-- Usuario generico (consulta)
CREATE USER PRY2205_EFT_DES IDENTIFIED BY "NoviembrE2025"
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA 10M ON USERS;

-- Usuario generico (consulta)
CREATE USER PRY2205_EFT_CON IDENTIFIED BY "SeptiembrE2025"
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA 10M ON USERS;

-- PRIVILEGIOS DE ROLES Y USUARIOS--

-- Rol del due?o: puede crear objetos y conectarse
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE,
CREATE SYNONYM,CREATE PUBLIC SYNONYM
TO PRY2205_EFT;


-- Rol limitado: usuario de consulta con permisos m?nimos
GRANT CREATE SESSION, CREATE VIEW, CREATE PROFILE,
CREATE USER, CREATE TABLE,CREATE PUBLIC SYNONYM
TO PRY2205_ROL_D;

-- Rol limitado: usuario de consulta con permisos m?nimos
GRANT CREATE SESSION
TO PRY2205_ROL_C;

-- asignacion de roles a los usuarios -- 
GRANT PRY2205_ROL_D TO PRY2205_EFT_DES;
GRANT PRY2205_ROL_C TO PRY2205_EFT_CON;

-- creacion de permisos para visualizaci�n de tablas --
GRANT SELECT ON PRY2205_EFT.PROFESIONAL TO PRY2205_ROL_D;
GRANT SELECT ON PRY2205_EFT.PROFESION TO PRY2205_ROL_D;
GRANT SELECT ON PRY2205_EFT.ISAPRE TO PRY2205_ROL_D;
GRANT SELECT ON PRY2205_EFT.TIPO_CONTRATO TO PRY2205_ROL_D;

-- creacion de sinonimos --
CREATE OR REPLACE PUBLIC SYNONYM PROFESIONAL FOR PRY2205_EFT.PROFESIONAL;
CREATE OR REPLACE PUBLIC SYNONYM PROFESION FOR PRY2205_EFT.PROFESION;
CREATE OR REPLACE PUBLIC SYNONYM ISAPRE FOR PRY2205_EFT.ISAPRE;
CREATE OR REPLACE PUBLIC SYNONYM TIPO_CONTRATO FOR PRY2205_EFT.TIPO_CONTRATO;

SHOW USER;
-- CASO 2 --
-- USUARIO PRY2205_EFT_DES --
------------------------------------------------------------
-- CREACION DE INFORMES

------------------------------------------------------------
-- REVISION DE TABLAS
SELECT * FROM PROFESIONAL
WHERE rutprof='172484794';
SELECT rutprof FROM PROFESIONAL;
SELECT sueldo FROM PROFESIONAL;
SELECT * FROM PROFESION;
SELECT * FROM ISAPRE;
SELECT * FROM TIPO_CONTRATO;

-- CREACION DE TABLA CONSULTA
DROP TABLE CARTOLA_PROFESIONALES CASCADE CONSTRAINTS;

CREATE TABLE CARTOLA_PROFESIONALES AS
SELECT
a.rutprof                                                                       AS "RUT_PROFESIONAL",
INITCAP(LOWER(a.nompro)) || ' ' || INITCAP(LOWER(a.apppro))|| ' ' || INITCAP(LOWER(a.apmpro)) AS "NOMBRE_PROFESIONAL",
b.nomprofesion                                                                  AS "PROFESION",
c.nomisapre                                                                     AS "ISAPRE",
a.sueldo                                                                        AS "SUELDO_BASE",
NVL(a.comision,0)                                                               AS "PORC_COMISION_PROFESIONAL",
a.sueldo*NVL(a.comision,0)                                                      AS "VALOR_TOTAL_COMISION",
CASE
WHEN a.sueldo BETWEEN 150000 AND 300000 THEN  a.sueldo*0.4
WHEN a.sueldo BETWEEN 300001 AND 500000 THEN  a.sueldo*0.38
WHEN a.sueldo BETWEEN 500001 AND 800000 THEN  a.sueldo*0.36
WHEN a.sueldo BETWEEN 800001 AND 1200000 THEN  a.sueldo*0.34
WHEN a.sueldo BETWEEN 1200001 AND 1500000 THEN  a.sueldo*0.30
WHEN a.sueldo BETWEEN 1500001 AND 2000000 THEN  a.sueldo*0.28
WHEN a.sueldo BETWEEN 2000001 AND 3000000 THEN  a.sueldo*0.26
WHEN a.sueldo BETWEEN 3000001 AND 5000000 THEN  a.sueldo*0.24
END                                                                             AS "PORCENTAJE_HONORARIO",
CASE
WHEN d.IDTCONTRATO='1' THEN 150000
WHEN d.IDTCONTRATO='2' THEN 120000
WHEN d.IDTCONTRATO='3' THEN 60000
WHEN d.IDTCONTRATO='4' THEN 50000
END                                                                             AS "BONO_MOVILIZACION",
TRUNC(a.sueldo+NVL(a.comision,0)+a.sueldo*NVL(a.comision,0) +
    CASE
        WHEN a.sueldo BETWEEN 150000 AND 300000 THEN a.sueldo * 0.40
        WHEN a.sueldo BETWEEN 300001 AND 500000 THEN a.sueldo * 0.38
        WHEN a.sueldo BETWEEN 500001 AND 800000 THEN a.sueldo * 0.36
        WHEN a.sueldo BETWEEN 800001 AND 1200000 THEN a.sueldo * 0.34
        WHEN a.sueldo BETWEEN 1200001 AND 1500000 THEN a.sueldo * 0.30
        WHEN a.sueldo BETWEEN 1500001 AND 2000000 THEN a.sueldo * 0.28
        WHEN a.sueldo BETWEEN 2000001 AND 3000000 THEN a.sueldo * 0.26
        WHEN a.sueldo BETWEEN 3000001 AND 5000000 THEN a.sueldo * 0.24
        ELSE 0
    END
    +
    CASE
        WHEN d.IDTCONTRATO = '1' THEN 150000
        WHEN d.IDTCONTRATO = '2' THEN 120000
        WHEN d.IDTCONTRATO = '3' THEN 60000
        WHEN d.IDTCONTRATO = '4' THEN 50000
        ELSE 0
    END
)                                                                               AS "TOTAL_PAGAR"
FROM PROFESIONAL a
INNER JOIN PROFESION b
ON a.idprofesion=b.idprofesion
INNER JOIN ISAPRE c
ON a.idisapre=c.idisapre
INNER JOIN tipo_contrato d
ON a.idtcontrato=d.idtcontrato;

-- VISTA ORDENADA
SELECT *
FROM CARTOLA_PROFESIONALES
ORDER BY PROFESION,SUELDO_BASE DESC,VALOR_TOTAL_COMISION,RUT_PROFESIONAL;  
                                                                            
-- PERMISO PARA USUARIO PRY2205_EFT_CON
GRANT SELECT ON PRY2205_EFT_DES.CARTOLA_PROFESIONALES TO PRY2205_ROL_C;

CREATE OR REPLACE PUBLIC SYNONYM CARTOLA_PROFESIONALES FOR PRY2205_EFT_DES.CARTOLA_PROFESIONALES;

SHOW USER;
-- CASO 3 --
-- USUARIO PRY2205_EFT --
-- OPTIMIZACION DE SENTENCIAS
------------------------------------------------------------
-- 3.1 CREACION DE VISTA

------------------------------------------------------------
-- VISTA DE TABLAS
SELECT * FROM EMPRESA;
SELECT * FROM ASESORIA;

-- CREACION DE VISTA
CREATE OR REPLACE VIEW VW_EMPRESAS_ASESORADAS AS
SELECT 
TO_CHAR(a.rut_empresa, '999G999G999')||'-'||a.dv_empresa                        AS "RUT_EMPRESA",
UPPER(a.nomempresa)                                                             AS "NOMBRE_EMPRESA",
a.iva_declarado                                                                 AS "IVA",
TRUNC(MONTHS_BETWEEN(SYSDATE, a.fecha_iniciacion_actividades) / 12)             AS "ANIOS_EXISTENCIA",
TRUNC(t.prom_anual)                                                             AS "TOTAL_ASESORIAS_ANUALES",
TRUNC(a.iva_declarado*(ROUND(t.prom_anual)/100))                                       AS "DEVOLUCION_IVA",
CASE
WHEN TRUNC(t.prom_anual)>5  THEN 'CLIENTE PREMIUM'
WHEN TRUNC(t.prom_anual) BETWEEN 3 AND 5 THEN 'CLIENTE'
WHEN TRUNC(t.prom_anual)<3  THEN 'CLIENTE POCO CONCURRIDO'
END                                                                             AS "TIPO_CLIENTE",
CASE
WHEN TRUNC(t.prom_anual)>=7 THEN '1 ASESORIA GRATIS'
WHEN TRUNC(t.prom_anual)= 6 THEN '1 ASESORIA 40% DESCUENTO'
WHEN TRUNC(t.prom_anual)=5 THEN '1 ASESORIA 30% DESCUENTO'
WHEN TRUNC(t.prom_anual) BETWEEN 3 AND 4 THEN '1 ASESORIA 20% DESCUENTO'
WHEN TRUNC(t.prom_anual)<3 THEN 'CAPTAR CLIENTE'
END                                                                             AS "CORRESPONDE"
FROM ((select x.idempresa,COUNT (x.rutprof)/12 AS PROM_ANUAL
FROM ASESORIA x
WHERE (EXTRACT(YEAR FROM fin) = EXTRACT(YEAR FROM SYSDATE)-1)
GROUP BY idempresa)
) t
JOIN EMPRESA a
ON a.idempresa=t.idempresa
WHERE EXISTS (
    SELECT 1
    FROM ASESORIA b
    WHERE b.idempresa = a.idempresa
      AND EXTRACT(YEAR FROM b.fin) = EXTRACT(YEAR FROM SYSDATE) - 1
)
ORDER BY UPPER(a.nomempresa) ASC;

-- PERMISO PARA USUARIO PRY2205_EFT_CON
GRANT SELECT ON PRY2205_EFT.VW_EMPRESAS_ASESORADAS TO PRY2205_ROL_C;

CREATE OR REPLACE PUBLIC SYNONYM VW_EMPRESAS_ASESORADAS FOR PRY2205_EFT.VW_EMPRESAS_ASESORADAS;


------------------------------------------------------------
-- CASO 3.2. CREACION DE INDICES 

------------------------------------------------------------
DROP INDEX IDX_VW_EMPRESAS_ASESORADAS;
DROP INDEX IDX_VW_EMPRESAS_ASESORADAS_iva;


SELECT * FROM VW_EMPRESAS_ASESORADAS;

CREATE INDEX IDX_VW_EMPRESAS_ASESORADAS
ON ASESORIA(fin);

CREATE INDEX IDX_VW_EMPRESAS_ASESORADAS_iva
ON EMPRESA(iva_declarado);


SHOW USER;
-- USUARIO PRY2205_EFT_CON --
------------------------------------------------------------
-- permisos del caso 2 y caso 3

------------------------------------------------------------
-- vista de la tabla CARTOLA_PROFESIONALES del caso 2
select *
FROM CARTOLA_PROFESIONALES;

-- vista del caso 3
SELECT * FROM VW_EMPRESAS_ASESORADAS;
