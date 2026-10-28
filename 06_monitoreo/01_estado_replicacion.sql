-- Paso 6: revisar que la replicación esté trabajando bien
--
-- Aquí se ve:
--   si los 4 agentes están encendidos (2 lectores del registro y
--   2 agentes que entregan los cambios)
--   el último mensaje de cada agente, por ejemplo cuántos cambios entregó
--   si hubo algún error
--
-- En Windows, esto mismo se puede ver con ventanas en SSMS, desde
-- Replication > Launch Replication Monitor.

SET NOCOUNT ON;

-- Los agentes y si están corriendo o detenidos
SELECT j.name AS Agente,
       CASE c.name WHEN 'REPL-LogReader' THEN 'Lector del registro'
                   ELSE 'Entrega de cambios' END AS Tipo,
       IIF(ja.start_execution_date IS NOT NULL AND ja.stop_execution_date IS NULL, 'EN EJECUCIÓN', 'DETENIDO') AS Estado
FROM msdb.dbo.sysjobs j
JOIN msdb.dbo.syscategories c ON c.category_id = j.category_id
OUTER APPLY (SELECT TOP 1 start_execution_date, stop_execution_date
             FROM msdb.dbo.sysjobactivity a WHERE a.job_id = j.job_id
             ORDER BY a.session_id DESC) ja
WHERE c.name IN ('REPL-LogReader', 'REPL-Distribution')
ORDER BY c.name, j.name;

-- Lo último que reportó cada lector del registro
SELECT a.publisher_db AS BaseQuePublica, h.time AS Hora, h.comments AS Mensaje
FROM distribution.dbo.MSlogreader_agents a
CROSS APPLY (SELECT TOP 1 time, comments FROM distribution.dbo.MSlogreader_history
             WHERE agent_id = a.id ORDER BY time DESC) h;

-- Lo último que reportó cada agente de entrega
SELECT a.publication AS Publicacion, a.subscriber_db AS BaseQueRecibe, h.time AS Hora,
       h.delivered_commands AS CambiosEntregados, h.comments AS Mensaje
FROM distribution.dbo.MSdistribution_agents a
CROSS APPLY (SELECT TOP 1 time, delivered_commands, comments FROM distribution.dbo.MSdistribution_history
             WHERE agent_id = a.id ORDER BY time DESC) h;

-- Errores recientes. Si todo está bien, esta consulta sale vacía.
SELECT TOP 5 time AS Hora, error_code AS Codigo, error_text AS Error
FROM distribution.dbo.MSrepl_errors
ORDER BY time DESC;
