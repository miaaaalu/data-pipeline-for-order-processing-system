import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
job.commit()

## read source data 
prd_feature = spark.read.parquet("s3://data-lake-bucket-imba/features/prd_feature_db")
up_features = spark.read.parquet("s3://data-lake-bucket-imba/features/up_features_db")
user_features_1 = spark.read.parquet("s3://data-lake-bucket-imba/features/user_feature1_db")
user_features_2 = spark.read.parquet("s3://data-lake-bucket-imba/features/user_features_2_db")

## join tables 
joinDF = ((up_features.join(prd_feature, "product_id")).join(user_features_1, "user_id")).join(user_features_2, "user_id")

## convert and export to S3
singleDF = joinDF.repartition(1)
singleDF.write.csv("s3://data-lake-bucket-imba/features/gluejobResult", header = "true")
