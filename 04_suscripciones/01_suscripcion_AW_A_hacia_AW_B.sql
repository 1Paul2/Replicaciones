-- Paso 4.1: suscribir AW_B a la publicación de AW_A
--
-- Suscribirse es como inscribirse a un periódico: AW_B se inscribe para
-- recibir todos los cambios que AW_A publique.
--
-- Opciones importantes:
--   sync_type = 'replication support only': como las dos bases ya tienen
--     los mismos datos, no se copia nada al inicio. Solo se preparan las
--     herramientas para recibir los cambios nuevos.
--   loopback_detection = 'true': esta es la clave para que la copia vaya
--     en los dos sentidos. Sin esta opción, un cambio hecho en AW_A
--     viajaría a AW_B, de AW_B volvería a AW_A, y así para siempre. Con
--     ella, un cambio nunca regresa a la base donde nació.
--   frequency_type = 64: el agente que entrega los cambios trabaja todo
--     el tiempo, sin pausas.
--
-- Nota: este archivo usa $(SA_PASSWORD) (modo SQLCMD).

USE AW_A;
GO
DECLARE @servidor sysname = @@SERVERNAME;

-- Crear la suscripción
EXEC sp_addsubscription
     @publication        = N'Pub_AW_A',
     @subscriber         = @servidor,
     @destination_db     = N'AW_B',
     @subscription_type  = N'Push',
     @sync_type          = N'replication support only',
     @article            = N'all',
     @update_mode        = N'read only',
     @loopback_detection = N'true';

-- Crear el "agente de distribución", el que entrega los cambios en AW_B.
-- "Push" significa que la base que envía es la que empuja los cambios
-- hacia la base que recibe.
EXEC sp_addpushsubscription_agent
     @publication              = N'Pub_AW_A',
     @subscriber               = @servidor,
     @subscriber_db            = N'AW_B',
     @job_login                = NULL,
     @job_password             = NULL,
     @subscriber_security_mode = 0,
     @subscriber_login         = N'sa',
     @subscriber_password      = N'$(SA_PASSWORD)',
     @frequency_type           = 64;
GO

-- Comprobación: "subscription status" debe ser 2 (activa) y
-- "loopback_detection" debe ser 1.
EXEC sp_helpsubscription @publication = N'Pub_AW_A';
