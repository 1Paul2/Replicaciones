-- Paso 4.2: suscribir AW_A a la publicación de AW_B
--
-- Es el camino de regreso: ahora AW_A se inscribe para recibir los
-- cambios que haga AW_B. Con esto y el paso 4.1, los cambios viajan en
-- los dos sentidos.
--
-- Las opciones son las mismas del paso 4.1. La más importante vuelve a
-- ser loopback_detection, que evita que los cambios reboten sin fin
-- entre las dos bases.
--
-- Nota: este archivo usa $(SA_PASSWORD) (modo SQLCMD).

USE AW_B;
GO
DECLARE @servidor sysname = @@SERVERNAME;

-- Crear la suscripción
EXEC sp_addsubscription
     @publication        = N'Pub_AW_B',
     @subscriber         = @servidor,
     @destination_db     = N'AW_A',
     @subscription_type  = N'Push',
     @sync_type          = N'replication support only',
     @article            = N'all',
     @update_mode        = N'read only',
     @loopback_detection = N'true';

-- Crear el agente que entrega los cambios en AW_A, trabajando sin pausas
EXEC sp_addpushsubscription_agent
     @publication              = N'Pub_AW_B',
     @subscriber               = @servidor,
     @subscriber_db            = N'AW_A',
     @job_login                = NULL,
     @job_password             = NULL,
     @subscriber_security_mode = 0,
     @subscriber_login         = N'sa',
     @subscriber_password      = N'$(SA_PASSWORD)',
     @frequency_type           = 64;
GO

-- Comprobación: "subscription status" debe ser 2 (activa) y
-- "loopback_detection" debe ser 1.
EXEC sp_helpsubscription @publication = N'Pub_AW_B';
