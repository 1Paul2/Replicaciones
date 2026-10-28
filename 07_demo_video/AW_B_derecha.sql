-- Demo para el video: ventana de AW_B (ponla a la derecha)
--
-- Esta ventana tiene los turnos pares. Empieza después de ejecutar el
-- turno 1 en la ventana de AW_A.

USE AW_B;

-- Turno 2: ver que llegó el casco creado en AW_A (su ID está cerca de
-- 1000) y crear unos guantes aquí en AW_B
SELECT ProductID, Name, ProductNumber, Color, ListPrice
FROM Production.Product WHERE ProductNumber LIKE 'DEMO-%';

INSERT Production.Product (Name, ProductNumber, SafetyStockLevel, ReorderPoint, StandardCost,
                           ListPrice, DaysToManufacture, SellStartDate, Color)
VALUES (N'DEMO Guantes desde AW_B', N'DEMO-B1', 10, 5, 8.00, 15.00, 0, GETDATE(), N'Blue');

-- Turno 4: ver que los guantes ahora cuestan 99.99 (lo cambió AW_A) y
-- pintar el casco de rojo
SELECT ProductID, Name, ProductNumber, Color, ListPrice
FROM Production.Product WHERE ProductNumber LIKE 'DEMO-%';

UPDATE Production.Product
   SET Color = N'Red', ModifiedDate = GETDATE()
 WHERE ProductNumber = N'DEMO-A1';

-- Turno 6: ver que los guantes desaparecieron (los borró AW_A) y borrar
-- el casco
SELECT ProductID, Name, ProductNumber, Color, ListPrice
FROM Production.Product WHERE ProductNumber LIKE 'DEMO-%';

DELETE Production.Product WHERE ProductNumber = N'DEMO-A1';

-- Turno 8: la consulta debe salir vacía, igual que en AW_A
SELECT ProductID, Name, ProductNumber, Color, ListPrice
FROM Production.Product WHERE ProductNumber LIKE 'DEMO-%';
