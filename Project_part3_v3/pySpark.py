# Create data frames from the source tables 
prd_feature = spark.read.parquet("s3://data-lake-bucket-imba/features/prd_feature_db")
prd_feature.show(10)
prd_feature.printSchema()
print("Count: ", prd_feature.count())

up_features = spark.read.parquet("s3://data-lake-bucket-imba/features/up_features_db")
up_features.show(10)
up_features.printSchema()
print("Count: ", up_features.count())

user_features_1 = spark.read.parquet("s3://data-lake-bucket-imba/features/user_feature1_db")
user_features_1.show(10)
user_features_1.printSchema()
print("Count: ", user_features_1.count())

user_features_2 = spark.read.parquet("s3://data-lake-bucket-imba/features/user_features_2_db")
user_features_2.show(10)
user_features_2.printSchema()
print("Count: ", user_features_2.count())

# Join the data frames 
joinDF = ((up_features.join(prd_feature, "product_id")).join(user_features_1, "user_id")).join(user_features_2, "user_id")
joinDF.show(10)
joinDF.printSchema()
print("Count: ", joinDF.count())

# Write out a single file to S3 directory "finaltable"
singleDF = joinDF.repartition(1)
singleDF.write.csv("s3://data-lake-bucket-imba/features/finaltable", header = "true")