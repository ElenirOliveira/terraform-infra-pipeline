from pyspark.sql import SparkSession

spark = SparkSession.builder.getOrCreate()

df = spark.read.option("header", "true").csv("s3://data-lake-earaujoo-2026-pipeline/raw/DimAccount.csv")

df_clean = df.dropDuplicates()

df_clean.write.mode("overwrite").parquet("s3://data-lake-earaujoo-2026-pipeline/silver/dim_account/")