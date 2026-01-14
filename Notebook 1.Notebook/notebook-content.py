# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "a92557fb-81c3-49c6-9b96-525aa692014d",
# META       "default_lakehouse_name": "ecommerce_analytics_lh",
# META       "default_lakehouse_workspace_id": "f462b0e6-32d1-486f-a6c7-2be51f9072f6",
# META       "known_lakehouses": [
# META         {
# META           "id": "a92557fb-81c3-49c6-9b96-525aa692014d"
# META         }
# META       ]
# META     }
# META   }
# META }

# CELL ********************

IF SCHEMA_ID('bronze')  IS NULL EXEC('CREATE SCHEMA bronze;');
IF SCHEMA_ID('silver')  IS NULL EXEC('CREATE SCHEMA silver;');
IF SCHEMA_ID('gold')    IS NULL EXEC('CREATE SCHEMA gold;');


base = "Files/bronze"  # OneLake-Datei-Ebene

# CSVs lesen
customers_df   = spark.read.option("header", True).option("inferSchema", True).csv(f"{base}/ecom_customers.csv")
products_df    = spark.read.option("header", True).option("inferSchema", True).csv(f"{base}/ecom_products.csv")
orders_df      = spark.read.option("header", True).option("inferSchema", True).csv(f"{base}/ecom_orders.csv")
order_items_df = spark.read.option("header", True).option("inferSchema", True).csv(f"{base}/ecom_order_items.csv")
reviews_df     = spark.read.option("header", True).option("inferSchema", True).csv(f"{base}/ecom_reviews.csv")

# In die Table-Ebene (Delta) schreiben → Schema 'bronze'
customers_df.write.mode("overwrite").saveAsTable("bronze.bronze_customers")
products_df.write.mode("overwrite").saveAsTable("bronze.bronze_products")
orders_df.write.mode("overwrite").saveAsTable("bronze.bronze_orders")
order_items_df.write.mode("overwrite").saveAsTable("bronze.bronze_order_items")
reviews_df.write.mode("overwrite").saveAsTable("bronze.bronze_reviews")

# Schnell prüfen
display(spark.sql("SHOW TABLES IN bronze"))


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

spark.sql("SELECT * FROM bronze_orders LIMIT 5").show()
spark.sql("SELECT * FROM bronze_order_items LIMIT 5").show()
spark.sql("SELECT * FROM bronze_customers LIMIT 5").show()
spark.sql("SELECT * FROM bronze_products LIMIT 5").show()
spark.sql("SELECT * FROM bronze_reviews LIMIT 5").show()

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
