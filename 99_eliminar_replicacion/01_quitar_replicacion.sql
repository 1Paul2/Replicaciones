-- Paso 99: quitar toda la replicación
--
-- Sirve para dejar el servidor como estaba y poder empezar de cero.
-- Se desarma en el orden contrario al que se armó:
--   0. se apagan los agentes (si siguen leyendo, no dejan borrar nada)
--   1. se cancelan las suscripciones
--   2. se borran las publicaciones
--   3. las bases dejan de compartir datos
--   4. se elimina el distribuidor
-- Los datos de las tablas NO se borran.

SET NOCOUNT ON;
DECLARE @servidor sysname = @@SERVERNAME;

-- 0. Apagar los agentes de replicación que estén corriendo y esperar un
-- momento a que suelten las bases
DECLARE @agente sysname;
DECLARE agentes CURSOR LOCAL FAST_FORWARD FOR
    SELECT j.name
    FROM msdb.dbo.sysjobs j
    JOIN msdb.dbo.syscategories c ON c.category_id = j.category_id
    JOIN msdb.dbo.sysjobactivity a ON a.job_id = j.job_id
    WHERE c.name IN ('REPL-LogReader', 'REPL-Distribution')
      AND a.session_id = (SELECT MAX(session_id) FROM msdb.dbo.syssessions)
      AND a.start_execution_date IS NOT NULL AND a.stop_execution_date IS NULL;
OPEN agentes;
FETCH NEXT FROM agentes INTO @agente;
WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC msdb.dbo.sp_stop_job @job_name = @agente;
    FETCH NEXT FROM agentes INTO @agente;
END;
CLOSE agentes;
DEALLOCATE agentes;
WAITFOR DELAY '00:00:05';

-- 1 y 2. Suscripción y publicación de AW_A (solo si existen)
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'AW_A' AND is_published = 1)
BEGIN
    EXEC AW_A..sp_dropsubscription @publication = N'Pub_AW_A', @article = N'all', @subscriber = @servidor;
    EXEC AW_A..sp_droppublication  @publication = N'Pub_AW_A';
END;

-- 1 y 2. Suscripción y publicación de AW_B (solo si existen)
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'AW_B' AND is_published = 1)
BEGIN
    EXEC AW_B..sp_dropsubscription @publication = N'Pub_AW_B', @article = N'all', @subscriber = @servidor;
    EXEC AW_B..sp_droppublication  @publication = N'Pub_AW_B';
END;

-- 3. Las bases dejan de compartir datos y se limpia lo que quedó de la
-- replicación dentro de ellas
EXEC sp_replicationdboption @dbname = N'AW_A', @optname = N'publish', @value = N'false';
EXEC sp_replicationdboption @dbname = N'AW_B', @optname = N'publish', @value = N'false';
EXEC sp_removedbreplication @dbname = N'AW_A';
EXEC sp_removedbreplication @dbname = N'AW_B';

-- 4. Eliminar el distribuidor y su base "distribution"
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'distribution')
    EXEC sp_dropdistributor @no_checks = 1, @ignore_distributor = 1;
