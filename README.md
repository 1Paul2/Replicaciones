# Replicaciones entre AW_A y AW_B

Investigación 2 de Bases de Datos II, Poll Garro Vargas. Replicación **bidireccional** en Microsoft SQL Server entre dos copias de AdventureWorks del mismo servidor. Se replican `INSERT`, `UPDATE` y `DELETE` sobre:

- `Production.ProductCategory`
- `Production.ProductSubcategory`
- `Production.Product`

Se usa **replicación transaccional bidireccional**: cada base publica sus tablas y está suscrita a la publicación de la otra, con `loopback_detection` activado.

La guía paso a paso y el guion del video están en documentos aparte (Word/PDF).

## Estructura

```
00_prerequisitos/        verificar servidor, Agente SQL y que los datos coincidan
01_preparar_tablas/      IDENTITY NOT FOR REPLICATION + rango propio de IDs en AW_B
02_distribuidor/         distribuidor local + base distribution
03_publicaciones/        Pub_AW_A y Pub_AW_B (3 artículos cada una)
04_suscripciones/        de AW_A hacia AW_B y de AW_B hacia AW_A (loopback_detection)
05_pruebas/              insertar, modificar, eliminar y comparar ambas bases
06_monitoreo/            estado de los agentes, historial y errores
07_demo_video/           dos ventanas (AW_A y AW_B) para la demostración del video
99_eliminar_replicacion/ desmonta todo para volver a empezar
scripts/ejecutar.sh      ejecuta los pasos en orden
```

## Uso rápido

```bash
cp .env.example .env              # poner la clave de sa
./scripts/ejecutar.sh configurar  # pasos 0 a 4
./scripts/ejecutar.sh probar      # paso 5
./scripts/ejecutar.sh monitorear  # paso 6
./scripts/ejecutar.sh quitar      # paso 99
```

Los scripts también se pueden abrir en Azure Data Studio, VS Code (mssql) o SSMS en **modo SQLCMD**. En ese caso hay que definir antes `:setvar SA_PASSWORD "tu_clave"`.
