# **Project_part3_v3**
## work flow
Business Requirement:

Factors that effect user behaviour to be created (Assume from DS team)
1. user (user_feature_1, user_feature_2)
2. product (prd_features)
3. preference = user + product (up_features)

High levels in Solution:
![](/Project_part3_v3/assets/part3-work-flow.jpg)

## AWS Glue DataBrew 
Data Preporcessing by Glue DataBrew. AWS Glue DataBrew is a visual data preparation tool that enables users to clean and normalize data without writing any code. DataBrew is serverless, can explore and transform terabytes of raw data without needing to create clusters or manage any infrastructure.

## 1. Create dataset
![](/Project_part3_v3/assets/create-dataset.png)

## 2. Create Projects with recipe (step function)
![](/Project_part3_v3/assets/create-projects.png)

## 3. Create jobs to load in S3 
![](/Project_part3_v3/assets/create-jobs.png)

## AWS glue development endpoint
For ETL scripts with outputs see [pySpark.ipynb](/Project_part3_v3/pySpark.ipynb)