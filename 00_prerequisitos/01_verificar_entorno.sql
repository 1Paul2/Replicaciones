-- Paso 0: revisar que todo esté listo antes de empezar
--
-- Antes de configurar la replicación hay que confirmar tres cosas:
--   1. Que el servidor sepa su propio nombre, porque los programas que
--      copian los datos se conectan usando ese nombre.
--   2. Que el Agente de SQL Server esté encendido. Es el "empleado" que
--      se encarga de mover los cambios de una base a la otra.
--   3. Que AW_A y AW_B tengan exactamente los mismos datos en las tres
--      tablas. Así no hace falta copiar nada al inicio.

SET NOCOUNT ON;

-- 1. Nombre del servidor. Las dos primeras columnas deben ser iguales.
SELECT @@SERVERNAME AS NombreRegistrado,
       SERVERPROPERTY('MachineName') AS NombreDelEquipo,
       IIF(@@SERVERNAME = CAST(SERVERPROPERTY('ServerName') AS sysname), 'OK', 'REVISAR') AS Estado;

-- 2. Servicios. Los dos deben decir "Running" (en ejecución).
SELECT servicename AS Servicio, status_desc AS Estado
FROM sys.dm_server_services;

-- 3. Las dos bases deben existir y estar en línea.
SELECT name AS Base, state_desc AS Estado
FROM sys.databases
WHERE name IN ('AW_A', 'AW_B');

-- 4. Cuántas filas tiene cada tabla en cada base. Deben coincidir.
SELECT 'AW_A' AS Base,
       (SELECT COUNT(*) FROM AW_A.Production.ProductCategory)    AS Categorias,
       (SELECT COUNT(*) FROM AW_A.Production.ProductSubcategory) AS Subcategorias,
       (SELECT COUNT(*) FROM AW_A.Production.Product)            AS Productos
UNION ALL
SELECT 'AW_B',
       (SELECT COUNT(*) FROM AW_B.Production.ProductCategory),
       (SELECT COUNT(*) FROM AW_B.Production.ProductSubcategory),
       (SELECT COUNT(*) FROM AW_B.Production.Product);

-- 5. Filas que están en AW_A pero no son iguales en AW_B. Todo debe dar 0.
SELECT
  (SELECT COUNT(*) FROM (SELECT * FROM AW_A.Production.ProductCategory    EXCEPT SELECT * FROM AW_B.Production.ProductCategory)    d) AS DiferenciasCategorias,
  (SELECT COUNT(*) FROM (SELECT * FROM AW_A.Production.ProductSubcategory EXCEPT SELECT * FROM AW_B.Production.ProductSubcategory) d) AS DiferenciasSubcategorias,
  (SELECT COUNT(*) FROM (SELECT * FROM AW_A.Production.Product            EXCEPT SELECT * FROM AW_B.Production.Product)            d) AS DiferenciasProductos;
