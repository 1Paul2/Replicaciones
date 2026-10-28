-- Paso 5.1: probar que los datos nuevos se copian
--
-- Cada base crea una categoría, una subcategoría dentro de ella y un
-- producto dentro de esa subcategoría:
--   AW_A crea "REPL Drones" con el producto "REPL Dron FPV X1"
--   AW_B crea "REPL Patinetas" con el producto "REPL Patineta E-200"
-- Después de esperar unos segundos, se revisa que cada cosa aparezca en
-- la otra base con el mismo número de ID.
--
-- Todos los datos de prueba empiezan con "REPL" o "RP-" para que sea
-- fácil reconocerlos y borrarlos.

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;

-- Si la prueba ya se había corrido antes, primero se borran los datos de
-- prueba viejos. Cada base borra solo lo que ella misma creó, y la
-- replicación se encarga de borrar la copia en la otra base.
DELETE AW_A.Production.Product            WHERE ProductNumber LIKE 'RP-%' AND ProductID < 1000000;
DELETE AW_A.Production.ProductSubcategory WHERE Name LIKE 'REPL %'     AND ProductSubcategoryID < 1000000;
DELETE AW_A.Production.ProductCategory    WHERE Name LIKE 'REPL %'     AND ProductCategoryID < 1000000;
DELETE AW_B.Production.Product            WHERE ProductNumber LIKE 'RP-%' AND ProductID >= 1000000;
DELETE AW_B.Production.ProductSubcategory WHERE Name LIKE 'REPL %'     AND ProductSubcategoryID >= 1000000;
DELETE AW_B.Production.ProductCategory    WHERE Name LIKE 'REPL %'     AND ProductCategoryID >= 1000000;
WAITFOR DELAY '00:00:10';

-- Datos nuevos en AW_A.
-- IDENT_CURRENT devuelve el último ID que se acaba de crear, para poder
-- usarlo en la fila hija.
DECLARE @cat int, @sub int;
INSERT AW_A.Production.ProductCategory (Name) VALUES (N'REPL Drones');
SET @cat = IDENT_CURRENT('AW_A.Production.ProductCategory');
INSERT AW_A.Production.ProductSubcategory (ProductCategoryID, Name) VALUES (@cat, N'REPL Drones FPV');
SET @sub = IDENT_CURRENT('AW_A.Production.ProductSubcategory');
INSERT AW_A.Production.Product (Name, ProductNumber, SafetyStockLevel, ReorderPoint, StandardCost,
                                ListPrice, DaysToManufacture, SellStartDate, ProductSubcategoryID, Color)
VALUES (N'REPL Dron FPV X1', N'RP-A001', 10, 5, 250.00, 499.99, 2, GETDATE(), @sub, N'Black');

-- Datos nuevos en AW_B
INSERT AW_B.Production.ProductCategory (Name) VALUES (N'REPL Patinetas');
SET @cat = IDENT_CURRENT('AW_B.Production.ProductCategory');
INSERT AW_B.Production.ProductSubcategory (ProductCategoryID, Name) VALUES (@cat, N'REPL Patinetas Eléctricas');
SET @sub = IDENT_CURRENT('AW_B.Production.ProductSubcategory');
INSERT AW_B.Production.Product (Name, ProductNumber, SafetyStockLevel, ReorderPoint, StandardCost,
                                ListPrice, DaysToManufacture, SellStartDate, ProductSubcategoryID, Color)
VALUES (N'REPL Patineta E-200', N'RP-B001', 8, 4, 180.00, 349.99, 1, GETDATE(), @sub, N'Blue');

-- Esperar 10 segundos para darle tiempo a la replicación
WAITFOR DELAY '00:00:10';

-- Revisión: cada fila de prueba debe decir "SÍ" en las dos columnas
-- EnAW_A y EnAW_B. La columna Origen dice en qué base se creó.
SELECT N'Categoría' AS Tabla, c.ProductCategoryID AS ID, c.Name AS Nombre,
       IIF(c.ProductCategoryID >= 1000000, 'AW_B', 'AW_A') AS Origen,
       IIF(a.ProductCategoryID IS NULL, 'NO', 'SÍ') AS EnAW_A,
       IIF(b.ProductCategoryID IS NULL, 'NO', 'SÍ') AS EnAW_B
FROM (SELECT ProductCategoryID, Name FROM AW_A.Production.ProductCategory WHERE Name LIKE 'REPL %'
      UNION SELECT ProductCategoryID, Name FROM AW_B.Production.ProductCategory WHERE Name LIKE 'REPL %') c
LEFT JOIN AW_A.Production.ProductCategory a ON a.ProductCategoryID = c.ProductCategoryID
LEFT JOIN AW_B.Production.ProductCategory b ON b.ProductCategoryID = c.ProductCategoryID
UNION ALL
SELECT N'Subcategoría', s.ProductSubcategoryID, s.Name,
       IIF(s.ProductSubcategoryID >= 1000000, 'AW_B', 'AW_A'),
       IIF(a.ProductSubcategoryID IS NULL, 'NO', 'SÍ'), IIF(b.ProductSubcategoryID IS NULL, 'NO', 'SÍ')
FROM (SELECT ProductSubcategoryID, Name FROM AW_A.Production.ProductSubcategory WHERE Name LIKE 'REPL %'
      UNION SELECT ProductSubcategoryID, Name FROM AW_B.Production.ProductSubcategory WHERE Name LIKE 'REPL %') s
LEFT JOIN AW_A.Production.ProductSubcategory a ON a.ProductSubcategoryID = s.ProductSubcategoryID
LEFT JOIN AW_B.Production.ProductSubcategory b ON b.ProductSubcategoryID = s.ProductSubcategoryID
UNION ALL
SELECT N'Producto', p.ProductID, p.Name,
       IIF(p.ProductID >= 1000000, 'AW_B', 'AW_A'),
       IIF(a.ProductID IS NULL, 'NO', 'SÍ'), IIF(b.ProductID IS NULL, 'NO', 'SÍ')
FROM (SELECT ProductID, Name FROM AW_A.Production.Product WHERE ProductNumber LIKE 'RP-%'
      UNION SELECT ProductID, Name FROM AW_B.Production.Product WHERE ProductNumber LIKE 'RP-%') p
LEFT JOIN AW_A.Production.Product a ON a.ProductID = p.ProductID
LEFT JOIN AW_B.Production.Product b ON b.ProductID = p.ProductID
ORDER BY Tabla, ID;
