-- Paso 3.1: crear la publicación de AW_A
--
-- Una publicación es la lista de tablas cuyos cambios se van a compartir.
-- Aquí AW_A anuncia: "voy a compartir lo que pase en Categorías,
-- Subcategorías y Productos".
--
-- Cada tabla de la lista se llama "artículo". Se agregan en orden de
-- padre a hijo: primero la categoría, luego la subcategoría que pertenece
-- a ella, y por último el producto que pertenece a la subcategoría.
--
-- Nota: este archivo usa $(SA_PASSWORD) (modo SQLCMD).

USE AW_A;
GO

-- 3.1.1 Permitir que AW_A comparta sus datos
EXEC sp_replicationdboption @dbname = N'AW_A', @optname = N'publish', @value = N'true';
GO

-- 3.1.2 Crear el "lector del registro" (Log Reader). Toda base guarda un
-- registro de cada cambio que se hace. Este agente lee ese registro y
-- lleva los cambios nuevos al distribuidor.
EXEC sp_addlogreader_agent
     @job_login = NULL, @job_password = NULL,
     @publisher_security_mode = 0,
     @publisher_login = N'sa', @publisher_password = N'$(SA_PASSWORD)';
GO

-- 3.1.3 Crear la publicación.
-- "continuous" significa que los cambios se envían todo el tiempo,
-- apenas ocurren, y no una vez al día.
EXEC sp_addpublication
     @publication       = N'Pub_AW_A',
     @description       = N'Categorías, subcategorías y productos de AW_A hacia AW_B',
     @status            = N'active',
     @repl_freq         = N'continuous',
     @sync_method       = N'concurrent',
     @allow_push        = N'true',
     @allow_pull        = N'true',
     @independent_agent = N'true',
     @immediate_sync    = N'false',
     @allow_anonymous   = N'false',
     @retention         = 0;
GO

-- 3.1.4 Agregar las tres tablas.
-- pre_creation_cmd = 'none': no borrar ni volver a crear la tabla en la
--   otra base, porque ya existe y ya tiene los datos.
-- identityrangemanagementoption = 'manual': los rangos de números de ID
--   ya los repartimos nosotros en el paso 1.
-- schema_option 0xA3: entre otras cosas, crea en la otra base los
--   procedimientos que se encargan de insertar, modificar y borrar.
EXEC sp_addarticle @publication = N'Pub_AW_A', @article = N'ProductCategory',
     @source_owner = N'Production', @source_object = N'ProductCategory',
     @destination_owner = N'Production', @destination_table = N'ProductCategory',
     @type = N'logbased', @pre_creation_cmd = N'none',
     @identityrangemanagementoption = N'manual', @schema_option = 0x00000000000000A3;

EXEC sp_addarticle @publication = N'Pub_AW_A', @article = N'ProductSubcategory',
     @source_owner = N'Production', @source_object = N'ProductSubcategory',
     @destination_owner = N'Production', @destination_table = N'ProductSubcategory',
     @type = N'logbased', @pre_creation_cmd = N'none',
     @identityrangemanagementoption = N'manual', @schema_option = 0x00000000000000A3;

EXEC sp_addarticle @publication = N'Pub_AW_A', @article = N'Product',
     @source_owner = N'Production', @source_object = N'Product',
     @destination_owner = N'Production', @destination_table = N'Product',
     @type = N'logbased', @pre_creation_cmd = N'none',
     @identityrangemanagementoption = N'manual', @schema_option = 0x00000000000000A3;
GO

-- Comprobación: deben aparecer las tres tablas de la publicación.
EXEC sp_helparticle @publication = N'Pub_AW_A';
