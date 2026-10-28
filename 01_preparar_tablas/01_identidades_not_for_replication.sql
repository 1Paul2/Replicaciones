-- Paso 1: preparar las tablas
--
-- Cada producto, categoría y subcategoría tiene un número de ID que la
-- base de datos pone sola (1, 2, 3...). Cuando las dos bases se copian
-- entre sí, eso causa dos problemas que se arreglan aquí:
--
-- Problema 1: si AW_A crea el producto 1000 y se lo manda a AW_B, AW_B
-- tiene que guardarlo con ese mismo número 1000 y no inventarse otro.
-- La opción NOT FOR REPLICATION le dice a la base: "cuando el dato venga
-- de la replicación, respeta el número que trae".
--
-- Problema 2: si las dos bases crean un producto al mismo tiempo, las dos
-- le pondrían el mismo número y chocarían. Para evitarlo, a cada base le
-- damos su propio rango de números:
--   AW_A sigue contando desde donde va (1000 en adelante)
--   AW_B empieza a contar desde 1 000 000

SET NOCOUNT ON;
GO

-- Problema 1: activar NOT FOR REPLICATION en las dos bases
USE AW_A;
GO
ALTER TABLE Production.ProductCategory    ALTER COLUMN ProductCategoryID    ADD NOT FOR REPLICATION;
ALTER TABLE Production.ProductSubcategory ALTER COLUMN ProductSubcategoryID ADD NOT FOR REPLICATION;
ALTER TABLE Production.Product            ALTER COLUMN ProductID            ADD NOT FOR REPLICATION;
GO
USE AW_B;
GO
ALTER TABLE Production.ProductCategory    ALTER COLUMN ProductCategoryID    ADD NOT FOR REPLICATION;
ALTER TABLE Production.ProductSubcategory ALTER COLUMN ProductSubcategoryID ADD NOT FOR REPLICATION;
ALTER TABLE Production.Product            ALTER COLUMN ProductID            ADD NOT FOR REPLICATION;
GO

-- Problema 2: mover el contador de AW_B a 1 000 000.
-- Solo se hace si todavía no está ahí, para poder correr este archivo
-- varias veces sin dañar nada.
IF IDENT_CURRENT('Production.ProductCategory') < 1000000
    DBCC CHECKIDENT ('Production.ProductCategory',    RESEED, 1000000) WITH NO_INFOMSGS;
IF IDENT_CURRENT('Production.ProductSubcategory') < 1000000
    DBCC CHECKIDENT ('Production.ProductSubcategory', RESEED, 1000000) WITH NO_INFOMSGS;
IF IDENT_CURRENT('Production.Product') < 1000000
    DBCC CHECKIDENT ('Production.Product',            RESEED, 1000000) WITH NO_INFOMSGS;
GO

-- Comprobación: la columna NotForReplication debe decir 1 en todas las
-- filas, y UltimoValor muestra en qué número va cada contador.
SELECT 'AW_A' AS Base, OBJECT_NAME(object_id, DB_ID('AW_A')) AS Tabla, name AS Columna,
       is_not_for_replication AS NotForReplication, last_value AS UltimoValor
FROM AW_A.sys.identity_columns
WHERE OBJECT_NAME(object_id, DB_ID('AW_A')) IN ('Product', 'ProductCategory', 'ProductSubcategory')
UNION ALL
SELECT 'AW_B', OBJECT_NAME(object_id, DB_ID('AW_B')), name, is_not_for_replication, last_value
FROM AW_B.sys.identity_columns
WHERE OBJECT_NAME(object_id, DB_ID('AW_B')) IN ('Product', 'ProductCategory', 'ProductSubcategory')
ORDER BY Base, Tabla;
