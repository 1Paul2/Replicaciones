-- Paso 5.2: probar que las modificaciones se copian
--
-- Para demostrar que la copia funciona en los dos sentidos, cada base
-- modifica lo que creó la OTRA:
--   AW_A cambia el precio de la patineta, que se creó en AW_B
--   AW_B cambia el color y el precio del dron, que se creó en AW_A,
--   y también el nombre de su categoría
--
-- Antes hay que correr el archivo 01_insertar.sql.

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;

-- Cambio hecho en AW_A
UPDATE AW_A.Production.Product
   SET ListPrice = 399.99, ModifiedDate = GETDATE()
 WHERE ProductNumber = N'RP-B001';

-- Cambios hechos en AW_B
UPDATE AW_B.Production.Product
   SET Color = N'Red', ListPrice = 549.99, ModifiedDate = GETDATE()
 WHERE ProductNumber = N'RP-A001';

UPDATE AW_B.Production.ProductCategory
   SET Name = N'REPL Drones y Accesorios', ModifiedDate = GETDATE()
 WHERE Name = N'REPL Drones';

-- Esperar 10 segundos para darle tiempo a la replicación
WAITFOR DELAY '00:00:10';

-- Revisión: se muestra el valor de cada base lado a lado. La columna
-- Resultado debe decir "IGUALES" en todas las filas.
SELECT a.ProductNumber, a.Name,
       a.Color AS Color_AW_A,      b.Color AS Color_AW_B,
       a.ListPrice AS Precio_AW_A, b.ListPrice AS Precio_AW_B,
       IIF(a.Color = b.Color AND a.ListPrice = b.ListPrice, 'IGUALES', 'DISTINTOS') AS Resultado
FROM AW_A.Production.Product a
JOIN AW_B.Production.Product b ON b.ProductID = a.ProductID
WHERE a.ProductNumber LIKE 'RP-%';

SELECT a.ProductCategoryID AS ID, a.Name AS Nombre_AW_A, b.Name AS Nombre_AW_B,
       IIF(a.Name = b.Name, 'IGUALES', 'DISTINTOS') AS Resultado
FROM AW_A.Production.ProductCategory a
JOIN AW_B.Production.ProductCategory b ON b.ProductCategoryID = a.ProductCategoryID
WHERE a.Name LIKE 'REPL %';
