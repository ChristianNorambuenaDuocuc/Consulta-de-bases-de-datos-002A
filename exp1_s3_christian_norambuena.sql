
--Listado de clientes con rango de renta(consulta 1)---

-- Formatos y reglas de la consulta sql 
SELECT 
--formato de rut
        TO_CHAR(numrut_cli, '999G999G999')||'-'||dvrut_cli as "RUT Cliente",
-- formato de nombre completo(concatenacion)           
        INITCAP(LOWER(nombre_cli))||' '|| INITCAP(LOWER(appaterno_cli))||' '||
        INITCAP(LOWER(apmaterno_cli)) as "Nombre Completo Cliente",
-- formato de direccion cliente(inicio con mayuscula)
        INITCAP(LOWER(direccion_cli))
        as "Direccion Cliente",
-- formato renta(miles y en pesos)        
        TO_CHAR(renta_cli, '$999G999G999') as "Renta Cliente",
-- formato de numero de celular(guion y rango de numeros)        
        '0' ||
        SUBSTR(TO_CHAR(celular_cli),1,1) || '-' ||
        SUBSTR(TO_CHAR(celular_cli),2,3) || '-' ||
        SUBSTR(TO_CHAR(celular_cli),5,4) AS "Celular Cliente",
-- condiciones de renta cliente(tramos)         
         CASE
         WHEN renta_cli>500000 THEN 'TRAMO 1'
         WHEN renta_cli BETWEEN 400000 AND 500000 THEN 'TRAMO 2'
         WHEN renta_cli BETWEEN 200000 AND 399999 THEN 'TRAMO 3'
         WHEN renta_cli<200000 THEN 'TRAMO 4'
       END AS "Tramo Renta Cliente"
-- Informacion de la tabla cliente
FROM CLIENTE
-- reglas de la consulta, renta minima y renta maxima como rango, solo acepta 
-- con numero de celular
WHERE  renta_cli BETWEEN &RENTA_MINIMA AND &RENTA_MAXIMA AND celular_cli IS NOT NULL
ORDER BY "Nombre Completo Cliente" asc;

--Sueldo promedio por categoria de empleados(consulta 2)---

SELECT 
        id_categoria_emp as "CODIGO_CATEGORIA",
-- Condiciones para establecer la descripcion de la categoria           
        CASE
        WHEN id_categoria_emp=1 THEN 'Gerente'
        WHEN id_categoria_emp=2 THEN 'Supervisor'
        WHEN id_categoria_emp=3 THEN 'Ejecutivo de Arriendo'
        WHEN id_categoria_emp=4 THEN 'Auxiliar'
        END as "DESCRIPCION_CATEGORIA",
-- Contar la cantidad de empleados
        COUNT(*)
        as "CANTIDAD_EMPLEADOS",
-- Condiciones para el tipo de sucursal de acuerdo al id sucursal        
        CASE
        WHEN id_sucursal=10 THEN 'Sucursal Las Condes'
        WHEN id_sucursal=20 THEN 'Sucursal Santiago Centro'
        WHEN id_sucursal=30 THEN 'Sucursal Providencia'
        WHEN id_sucursal=40 THEN 'Sucursal Vitacura'
        END as "SUCURSAL",
-- promedio de sueldos con formato en miles y en pesos.        
        TO_CHAR(AVG(sueldo_emp),'$999G999G999') AS "SUELDO_PROMEDIO"
         
FROM EMPLEADO
-- agrupado por id_categoria_emp
GROUP BY id_categoria_emp,CASE
        WHEN id_sucursal=10 THEN 'Sucursal Las Condes'
        WHEN id_sucursal=20 THEN 'Sucursal Santiago Centro'
        WHEN id_sucursal=30 THEN 'Sucursal Providencia'
        WHEN id_sucursal=40 THEN 'Sucursal Vitacura'
        END 
-- Condiciones asociada al promedio de sueldo        
HAVING AVG(sueldo_emp)>&SUELDO_PROMEDIO_MINIMO
ORDER BY AVG(sueldo_emp) desc;

--Arriendo promedio por tipo de propiedad(consulta 3)---

SELECT 
        id_tipo_propiedad as "CODIGO_TIPO",
-- Condicion se acuerdo al id de propiedad.           
        CASE
        WHEN id_tipo_propiedad='A' THEN 'CASA'
        WHEN id_tipo_propiedad='B' THEN 'DEPARTAMENTO'
        WHEN id_tipo_propiedad='C' THEN 'LOCAL'
        WHEN id_tipo_propiedad='D' THEN 'PARCELA SIN CASA'
        WHEN id_tipo_propiedad='E' THEN 'PARCELA CON CASA'
        END as "DESCRIPCION_TIPO",
-- Contar las propiedades
        COUNT(*)
        as "TOTAL_PROPIEDADES",
-- Formato en miles y en pesos del promedio de valor arriendo.        
        TO_CHAR(AVG(valor_arriendo),'$999G999G999') as "PROMEDIO_ARRIENDO",
-- Formato en 2 decimales(rellenar con 0) el promedio de la superficie.        
        TO_CHAR(ROUND(AVG(superficie),2),'FM999G999G999D00') AS "PROMEDIO_SUPERFICIE",
-- Formato de razon de valor de arriendo y superficie promedio         
        TO_CHAR(AVG(valor_arriendo/superficie),'$999G999G999')
        as "VALOR_ARRIENDO_M2",
-- Condicion para el monto de promedio de razon de valor arriendo y superficie         
        CASE
        WHEN AVG(valor_arriendo/superficie)<5000 THEN 'Economico'
        WHEN AVG(valor_arriendo/superficie) BETWEEN 5000 AND 10000 THEN 'Medio'
        WHEN AVG(valor_arriendo/superficie)>10000 THEN 'Alto'
        END as "CLASIFICACION"
        
FROM PROPIEDAD  
WHERE superficie IS NOT NULL AND valor_arriendo IS NOT NULL
AND NULLIF (superficie,0) IS NOT NULL
GROUP BY id_tipo_propiedad, CASE
        WHEN id_tipo_propiedad='A' THEN 'CASA'
        WHEN id_tipo_propiedad='B' THEN 'DEPARTAMENTO'
        WHEN id_tipo_propiedad='C' THEN 'LOCAL'
        WHEN id_tipo_propiedad='D' THEN 'PARCELA SIN CASA'
        WHEN id_tipo_propiedad='E' THEN 'PARCELA CON CASA'
        END 
HAVING AVG(valor_arriendo/superficie)>1000
ORDER BY AVG(valor_arriendo/superficie) desc;
