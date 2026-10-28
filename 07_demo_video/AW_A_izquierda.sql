-- Demo para el video: ventana de AW_A (ponla a la izquierda)
--
-- Las dos ventanas se turnan: turno 1 aquí, turno 2 en AW_B, turno 3
-- aquí, y así hasta el 8. Esta ventana tiene los turnos impares.
--
-- Para ejecutar solo un turno, selecciona su bloque con el mouse y
-- presiona Ctrl+Shift+E. Entre un turno y el siguiente espera unos
-- 5 segundos, que es lo que tarda la replicación en llevar el cambio.

USE AW_A;

-- Turno 1: crear un producto nuevo aquí en AW_A y verlo
INSERT Production.Product (Name, ProductNumber, SafetyStockLevel, ReorderPoint, StandardCost,
                           ListPrice, DaysToManufacture, SellStartDate, Color)
VALUES (N'DEMO Casco desde AW_A', N'DEMO-A1', 10, 5, 20.00, 45.00, 0, GETDATE(), N'Black');

SELECT ProductID, Name, ProductNumber, Color, ListPrice
FROM Production.Product WHERE ProductNumber LIKE 'DEMO-%';

-- Turno 3: ver que llegaron los guantes creados en AW_B (su ID está
-- cerca de 1 000 000) y cambiarles el precio
SELECT ProductID, Name, ProductNumber, Color, ListPrice
FROM Production.Product WHERE ProductNumber LIKE 'DEMO-%';

UPDATE Production.Product
   SET ListPrice = 99.99, ModifiedDate = GETDATE()
 WHERE ProductNumber = N'DEMO-B1';

-- Turno 5: ver que el casco ahora es rojo (lo cambió AW_B) y borrar los
-- guantes
SELECT ProductID, Name, ProductNumber, Color, ListPrice
FROM Production.Product WHERE ProductNumber LIKE 'DEMO-%';

DELETE Production.Product WHERE ProductNumber = N'DEMO-B1';

-- Turno 7: ver que también desapareció el casco (lo borró AW_B).
-- La consulta debe salir vacía.
SELECT ProductID, Name, ProductNumber, Color, ListPrice
FROM Production.Product WHERE ProductNumber LIKE 'DEMO-%';
