-- Paso 5.4: comparar las dos bases completas
--
-- Revisa las tres tablas enteras, fila por fila, y cuenta:
--   cuántas filas tiene cada base
--   cuántas filas están en AW_A y no son iguales en AW_B
--   cuántas filas están en AW_B y no son iguales en AW_A
-- Si la replicación está al día, las diferencias dan 0 y el estado dice
-- "SINCRONIZADAS".

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;

SELECT Tabla, FilasAW_A, FilasAW_B, SoloEnAW_A, SoloEnAW_B,
       IIF(SoloEnAW_A = 0 AND SoloEnAW_B = 0, 'SINCRONIZADAS', 'DIFERENTES') AS Estado
FROM (
    SELECT 'ProductCategory' AS Tabla,
        (SELECT COUNT(*) FROM AW_A.Production.ProductCategory) AS FilasAW_A,
        (SELECT COUNT(*) FROM AW_B.Production.ProductCategory) AS FilasAW_B,
        (SELECT COUNT(*) FROM (SELECT * FROM AW_A.Production.ProductCategory EXCEPT SELECT * FROM AW_B.Production.ProductCategory) d) AS SoloEnAW_A,
        (SELECT COUNT(*) FROM (SELECT * FROM AW_B.Production.ProductCategory EXCEPT SELECT * FROM AW_A.Production.ProductCategory) d) AS SoloEnAW_B
    UNION ALL
    SELECT 'ProductSubcategory',
        (SELECT COUNT(*) FROM AW_A.Production.ProductSubcategory),
        (SELECT COUNT(*) FROM AW_B.Production.ProductSubcategory),
        (SELECT COUNT(*) FROM (SELECT * FROM AW_A.Production.ProductSubcategory EXCEPT SELECT * FROM AW_B.Production.ProductSubcategory) d),
        (SELECT COUNT(*) FROM (SELECT * FROM AW_B.Production.ProductSubcategory EXCEPT SELECT * FROM AW_A.Production.ProductSubcategory) d)
    UNION ALL
    SELECT 'Product',
        (SELECT COUNT(*) FROM AW_A.Production.Product),
        (SELECT COUNT(*) FROM AW_B.Production.Product),
        (SELECT COUNT(*) FROM (SELECT * FROM AW_A.Production.Product EXCEPT SELECT * FROM AW_B.Production.Product) d),
        (SELECT COUNT(*) FROM (SELECT * FROM AW_B.Production.Product EXCEPT SELECT * FROM AW_A.Production.Product) d)
) t;
