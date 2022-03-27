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
singleDF.write.mode('overwrite').csv("s3://data-lake-bucket-imba/features/gluejobResult/", header = "true")