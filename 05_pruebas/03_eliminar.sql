-- Paso 5.3: probar que los borrados se copian
--
-- Otra vez cada base borra lo que creó la otra:
--   AW_B borra el dron, su subcategoría y su categoría (creados en AW_A)
--   AW_A borra la patineta, su subcategoría y su categoría (creados en AW_B)
--
-- Se borra primero el producto, luego la subcategoría y al final la
-- categoría, porque no se puede borrar una categoría que todavía tiene
-- cosas adentro.
--
-- Antes hay que correr el archivo 01_insertar.sql.

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;

-- Borrados hechos en AW_B
DELETE AW_B.Production.Product            WHERE ProductNumber = N'RP-A001';
DELETE AW_B.Production.ProductSubcategory WHERE Name = N'REPL Drones FPV';
DELETE AW_B.Production.ProductCategory    WHERE Name LIKE N'REPL Drones%';

-- Borrados hechos en AW_A
DELETE AW_A.Production.Product            WHERE ProductNumber = N'RP-B001';
DELETE AW_A.Production.ProductSubcategory WHERE Name = N'REPL Patinetas Eléctricas';
DELETE AW_A.Production.ProductCategory    WHERE Name = N'REPL Patinetas';

-- Esperar 10 segundos para darle tiempo a la replicación
WAITFOR DELAY '00:00:10';

-- Revisión: ya no debe quedar ningún dato de prueba en ninguna de las dos
-- bases, o sea, todo debe dar 0.
SELECT 'AW_A' AS Base,
       (SELECT COUNT(*) FROM AW_A.Production.ProductCategory    WHERE Name LIKE 'REPL %')        AS Categorias,
       (SELECT COUNT(*) FROM AW_A.Production.ProductSubcategory WHERE Name LIKE 'REPL %')        AS Subcategorias,
       (SELECT COUNT(*) FROM AW_A.Production.Product            WHERE ProductNumber LIKE 'RP-%') AS Productos
UNION ALL
SELECT 'AW_B',
       (SELECT COUNT(*) FROM AW_B.Production.ProductCategory    WHERE Name LIKE 'REPL %'),
       (SELECT COUNT(*) FROM AW_B.Production.ProductSubcategory WHERE Name LIKE 'REPL %'),
       (SELECT COUNT(*) FROM AW_B.Production.Product            WHERE ProductNumber LIKE 'RP-%');
