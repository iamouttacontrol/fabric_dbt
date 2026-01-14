-- Fabric notebook source

-- METADATA ********************

-- META {
-- META   "kernel_info": {
-- META     "name": "sqldatawarehouse"
-- META   },
-- META   "dependencies": {
-- META     "warehouse": {
-- META       "default_warehouse": "9633ee4b-7a8a-4946-9c6d-311c47f26647",
-- META       "known_warehouses": [
-- META         {
-- META           "id": "9633ee4b-7a8a-4946-9c6d-311c47f26647",
-- META           "type": "Lakewarehouse"
-- META         }
-- META       ]
-- META     }
-- META   }
-- META }

-- CELL ********************

-- Welcome to your new notebook
-- Type here in the cell editor to add code!


IF SCHEMA_ID('bronze') IS NULL EXEC('CREATE SCHEMA bronze;');
IF SCHEMA_ID('silver') IS NULL EXEC('CREATE SCHEMA silver;');
IF SCHEMA_ID('gold')   IS NULL EXEC('CREATE SCHEMA gold;');





-- METADATA ********************

-- META {
-- META   "language": "sql",
-- META   "language_group": "sqldatawarehouse"
-- META }

-- CELL ********************

-- Tabellen von dbo nach bronze verschieben
ALTER SCHEMA bronze TRANSFER dbo.bronze_customers;
ALTER SCHEMA bronze TRANSFER dbo.bronze_products;
ALTER SCHEMA bronze TRANSFER dbo.bronze_orders;
ALTER SCHEMA bronze TRANSFER dbo.bronze_order_items;
ALTER SCHEMA bronze TRANSFER dbo.bronze_reviews;

-- METADATA ********************

-- META {
-- META   "language": "sql",
-- META   "language_group": "sqldatawarehouse"
-- META }

-- MARKDOWN ********************


-- CELL ********************

SELECT TOP 5 * FROM bronze.bronze_orders;


-- METADATA ********************

-- META {
-- META   "language": "sql",
-- META   "language_group": "sqldatawarehouse"
-- META }

-- CELL ********************

----------------------------
-- 1) Views aus 'analytics' -> 'silver'
----------------------------
DECLARE @sql nvarchar(max) = N'';
SELECT @sql = STRING_AGG(
  'ALTER SCHEMA silver TRANSFER analytics.' + QUOTENAME(v.name) + ';', CHAR(10)
)
FROM sys.views v
JOIN sys.schemas s ON s.schema_id = v.schema_id
WHERE s.name = 'analytics';
IF @sql IS NOT NULL EXEC sp_executesql @sql;

----------------------------
-- 2) Tabellen aus 'analytics' -> 'gold'
----------------------------
SET @sql = N'';
SELECT @sql = STRING_AGG(
  'ALTER SCHEMA gold TRANSFER analytics.' + QUOTENAME(t.name) + ';', CHAR(10)
)
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE s.name = 'analytics';
IF @sql IS NOT NULL EXEC sp_executesql @sql;

----------------------------
-- 3) Leere analytics-Schemas droppen (falls leer)
----------------------------
IF NOT EXISTS (
  SELECT 1 FROM sys.objects o JOIN sys.schemas s ON s.schema_id = o.schema_id
  WHERE s.name = 'analytics'
)
    DROP SCHEMA analytics;

IF NOT EXISTS (
  SELECT 1 FROM sys.objects o JOIN sys.schemas s ON s.schema_id = o.schema_id
  WHERE s.name = 'analytics_silver'
)
    DROP SCHEMA analytics_silver;

IF NOT EXISTS (
  SELECT 1 FROM sys.objects o JOIN sys.schemas s ON s.schema_id = o.schema_id
  WHERE s.name = 'analytics_gold'
)
    DROP SCHEMA analytics_gold;


-- METADATA ********************

-- META {
-- META   "language": "sql",
-- META   "language_group": "sqldatawarehouse"
-- META }

-- CELL ********************

-- Reihenfolge: erst Views, dann Tabellen, dann Schemas
DECLARE @sql nvarchar(max);

-- Drop Views
SET @sql = (
  SELECT STRING_AGG('DROP VIEW ' + QUOTENAME(s.name) + '.' + QUOTENAME(o.name) + ';', CHAR(10))
  FROM sys.objects o
  JOIN sys.schemas s ON s.schema_id = o.schema_id
  WHERE s.name IN ('analytics','analytics_silver','analytics_gold') AND o.type = 'V'
);
IF @sql IS NOT NULL EXEC sp_executesql @sql;

-- Drop Tables
SET @sql = (
  SELECT STRING_AGG('DROP TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(o.name) + ';', CHAR(10))
  FROM sys.objects o
  JOIN sys.schemas s ON s.schema_id = o.schema_id
  WHERE s.name IN ('analytics','analytics_silver','analytics_gold') AND o.type = 'U'
);
IF @sql IS NOT NULL EXEC sp_executesql @sql;

-- Drop Schemas
IF EXISTS (SELECT 1 FROM sys.schemas WHERE name='analytics')        DROP SCHEMA analytics;
IF EXISTS (SELECT 1 FROM sys.schemas WHERE name='analytics_silver') DROP SCHEMA analytics_silver;
IF EXISTS (SELECT 1 FROM sys.schemas WHERE name='analytics_gold')   DROP SCHEMA analytics_gold;


-- METADATA ********************

-- META {
-- META   "language": "sql",
-- META   "language_group": "sqldatawarehouse"
-- META }

-- CELL ********************

-- zuerst Views, dann Tables
DECLARE @sql nvarchar(max);

SET @sql = (
  SELECT STRING_AGG('DROP VIEW '+QUOTENAME(s.name)+'.'+QUOTENAME(o.name)+';', CHAR(10))
  FROM sys.objects o JOIN sys.schemas s ON s.schema_id=o.schema_id
  WHERE s.name IN ('silver','gold') AND o.type='V'
);
IF @sql IS NOT NULL EXEC sp_executesql @sql;

SET @sql = (
  SELECT STRING_AGG('DROP TABLE '+QUOTENAME(s.name)+'.'+QUOTENAME(o.name)+';', CHAR(10))
  FROM sys.objects o JOIN sys.schemas s ON s.schema_id=o.schema_id
  WHERE s.name IN ('silver','gold') AND o.type='U'
);
IF @sql IS NOT NULL EXEC sp_executesql @sql;

IF EXISTS (SELECT 1 FROM sys.schemas WHERE name='silver') DROP SCHEMA silver;
IF EXISTS (SELECT 1 FROM sys.schemas WHERE name='gold')   DROP SCHEMA gold;


-- METADATA ********************

-- META {
-- META   "language": "sql",
-- META   "language_group": "sqldatawarehouse"
-- META }

-- CELL ********************

-- 0) Sicherheit: NICHT ausführen, wenn du noch Modelle nach 'analytics' schreibst!
--    (In dbt 'models:'-Schemas auf silver/gold oder anderes Schema umstellen)

-- 1) Alle Views im Schema 'analytics' droppen
DECLARE @sql nvarchar(max);
SET @sql = (
  SELECT STRING_AGG('DROP VIEW ' + QUOTENAME(s.name) + '.' + QUOTENAME(o.name) + ';', CHAR(10))
  FROM sys.objects o
  JOIN sys.schemas s ON s.schema_id = o.schema_id
  WHERE s.name = 'analytics' AND o.type = 'V'
);
IF @sql IS NOT NULL EXEC sp_executesql @sql;

-- 2) Alle Tabellen im Schema 'analytics' droppen
SET @sql = (
  SELECT STRING_AGG('DROP TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(o.name) + ';', CHAR(10))
  FROM sys.objects o
  JOIN sys.schemas s ON s.schema_id = o.schema_id
  WHERE s.name = 'analytics' AND o.type = 'U'
);
IF @sql IS NOT NULL EXEC sp_executesql @sql;

-- 3) Schema droppen (nur wenn jetzt leer)
IF NOT EXISTS (
  SELECT 1
  FROM sys.objects o
  JOIN sys.schemas s ON s.schema_id = o.schema_id
  WHERE s.name = 'analytics'
)
DROP SCHEMA analytics;


-- METADATA ********************

-- META {
-- META   "language": "sql",
-- META   "language_group": "sqldatawarehouse"
-- META }

-- MARKDOWN ********************

