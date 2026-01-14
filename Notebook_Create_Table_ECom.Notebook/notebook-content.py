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

# Welcome to your new notebook
# Type here in the cell editor to add code!

# Kunden
customers_df = spark.read.option("header", True).option("inferSchema", True).csv("Files/bronze/ecom_customers.csv")
customers_df.write.mode("overwrite").saveAsTable("bronze_customers")

# Produkte
products_df = spark.read.option("header", True).option("inferSchema", True).csv("Files/bronze/ecom_products.csv")
products_df.write.mode("overwrite").saveAsTable("bronze_products")

# Bestellungen
orders_df = spark.read.option("header", True).option("inferSchema", True).csv("Files/bronze/ecom_orders.csv")
orders_df.write.mode("overwrite").saveAsTable("bronze_orders")

# Bestellpositionen
order_items_df = spark.read.option("header", True).option("inferSchema", True).csv("Files/bronze/ecom_order_items.csv")
order_items_df.write.mode("overwrite").saveAsTable("bronze_order_items")

# Bewertungen
reviews_df = spark.read.option("header", True).option("inferSchema", True).csv("Files/bronze/ecom_reviews.csv")
reviews_df.write.mode("overwrite").saveAsTable("bronze_reviews")


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
