-- Paso 2: configurar el distribuidor
--
-- El distribuidor funciona como una oficina de correos. Cuando una base
-- hace un cambio, el cambio se deja en el distribuidor, y desde ahí se
-- entrega a la otra base. Los cambios esperan en una base de datos
-- especial llamada "distribution".
--
-- En este trabajo el mismo servidor hace los tres papeles: es quien
-- publica los cambios, quien los distribuye y quien los recibe.
--
-- Nota: este archivo usa $(SA_PASSWORD), que se reemplaza por la clave
-- del usuario sa al ejecutarlo en modo SQLCMD.

USE master;
GO

-- 2.1 Decirle al servidor que él mismo será el distribuidor
DECLARE @servidor sysname = @@SERVERNAME;

EXEC sp_adddistributor
     @distributor = @servidor,
     @password    = N'$(SA_PASSWORD)';

-- 2.2 Crear la base "distribution", donde esperan los cambios.
-- Los cambios ya entregados se guardan como máximo 72 horas.
EXEC sp_adddistributiondb
     @database          = N'distribution',
     @security_mode     = 1,
     @min_distretention = 0,
     @max_distretention = 72,
     @history_retention = 48;
GO

-- 2.3 Crear la carpeta de trabajo de la replicación.
-- En Linux, SQL Server guarda sus archivos dentro de /var/opt/mssql.
EXEC master.dbo.xp_create_subdir N'/var/opt/mssql/data/ReplData';
GO

-- 2.4 Registrar este servidor como "publicador", o sea, como alguien que
-- va a mandar cambios a través del distribuidor.
DECLARE @servidor sysname = @@SERVERNAME;
USE distribution;
EXEC sp_adddistpublisher
     @publisher         = @servidor,
     @distribution_db   = N'distribution',
     @security_mode     = 0,
     @login             = N'sa',
     @password          = N'$(SA_PASSWORD)',
     @working_directory = N'/var/opt/mssql/data/ReplData',
     @publisher_type    = N'MSSQLSERVER';
GO

-- Comprobación: "installed" y "distribution db installed" deben dar 1.
EXEC sp_get_distributor;
SELECT name, is_distributor FROM sys.databases WHERE name = 'distribution';
