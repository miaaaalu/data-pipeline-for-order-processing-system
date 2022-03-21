# AWS Glue jobs (3.0) for data transformations

The detailed explanations are commented below. Here is the high-level description:

* Create the Glue job with Spark script editor

* Read the source table (parquet) from S3
 
* Join the source table and converted

* Write table back to S3



## Glue Job Creation

* Name: test
* IAM Role: full access to Glue and S3
* Type: Spark
* Editor: Spark script editor
* Glue version: 3.0 - Spark 3.1, Scala 3, Python 3
* This job runs: A new script to be authored by owner

## Glue Script
```py
# IMPORT LIBRARIES
from pyspark.context import SparkContext
from awsglue.context import GlueContext

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session


# EXTRACT (READ DATA)
prd_feature = spark.read.parquet("s3://data-lake-bucket-imba/features/prd_feature_db")
up_features = spark.read.parquet("s3://data-lake-bucket-imba/features/up_features_db")
user_features_1 = spark.read.parquet("s3://data-lake-bucket-imba/features/user_feature1_db")
user_features_2 = spark.read.parquet("s3://data-lake-bucket-imba/features/user_features_2_db")


# TRANSFORM (MODIFY DATA)
joinDF = ((up_features.join(prd_feature, "product_id")).join(user_features_1, "user_id")).join(user_features_2, "user_id")


# LOAD (WRITE DATA)
singleDF = joinDF.repartition(1)
singleDF.write.csv("s3://data-lake-bucket-imba/features/gluejobResult", header = "true")
```
![](/Project_part4_v3/assets/gluejobresult.png)
![](/Project_part4_v3/assets/result-in-s3.png)