-- Paso 3.2: crear la publicación de AW_B
--
-- Es lo mismo que el paso 3.1, pero ahora es AW_B la que anuncia que va
-- a compartir sus cambios. Así cada base comparte lo suyo con la otra.
--
-- Nota: este archivo usa $(SA_PASSWORD) (modo SQLCMD).

USE AW_B;
GO

-- 3.2.1 Permitir que AW_B comparta sus datos
EXEC sp_replicationdboption @dbname = N'AW_B', @optname = N'publish', @value = N'true';
GO

-- 3.2.2 Crear el lector del registro de AW_B, que lleva sus cambios
-- al distribuidor.
EXEC sp_addlogreader_agent
     @job_login = NULL, @job_password = NULL,
     @publisher_security_mode = 0,
     @publisher_login = N'sa', @publisher_password = N'$(SA_PASSWORD)';
GO

-- 3.2.3 Crear la publicación, con envío continuo de los cambios
EXEC sp_addpublication
     @publication       = N'Pub_AW_B',
     @description       = N'Categorías, subcategorías y productos de AW_B hacia AW_A',
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

-- 3.2.4 Agregar las tres tablas, de padre a hijo (mismas opciones que en
-- el paso 3.1).
EXEC sp_addarticle @publication = N'Pub_AW_B', @article = N'ProductCategory',
     @source_owner = N'Production', @source_object = N'ProductCategory',
     @destination_owner = N'Production', @destination_table = N'ProductCategory',
     @type = N'logbased', @pre_creation_cmd = N'none',
     @identityrangemanagementoption = N'manual', @schema_option = 0x00000000000000A3;

EXEC sp_addarticle @publication = N'Pub_AW_B', @article = N'ProductSubcategory',
     @source_owner = N'Production', @source_object = N'ProductSubcategory',
     @destination_owner = N'Production', @destination_table = N'ProductSubcategory',
     @type = N'logbased', @pre_creation_cmd = N'none',
     @identityrangemanagementoption = N'manual', @schema_option = 0x00000000000000A3;

EXEC sp_addarticle @publication = N'Pub_AW_B', @article = N'Product',
     @source_owner = N'Production', @source_object = N'Product',
     @destination_owner = N'Production', @destination_table = N'Product',
     @type = N'logbased', @pre_creation_cmd = N'none',
     @identityrangemanagementoption = N'manual', @schema_option = 0x00000000000000A3;
GO

-- Comprobación: deben aparecer las tres tablas de la publicación.
EXEC sp_helparticle @publication = N'Pub_AW_B';
