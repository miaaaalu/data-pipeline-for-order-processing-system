# Building a serverless Automated ETL Pipeline and Recommendation Engine with AWS (on going)
## Architecture overview (update to project progress)
The following diagram illustrates the high-levle of project architecture:

![](/pipeline-update-v6.jpg)

## Step 1 Run Glue Crawler
Run an AWS Glue `crawler` to automatically generate the schema. A crawler can crawl multiple data stores in a single run. Upon completion, the crawler creates or updates one or more tables in the Data `Catalog`. `Athena` will use this catalog to run queries against the tables.


## Step 2 run SQL ETL in Athena 
After the raw data is cataloged, the source-to-target transformation is done through a series of `Athena` SQL statements. 

The transformed data is loaded into another `S3 bucket`. 

The files are also partitioned and converted into Parquet format to optimize performance and cost.

*About Athena*
* serverless
* no infrastructure to manage
* pay only for the queries that you run


## Step 3 ETL job in Glue Databrew 
use DataBrew to prepare and clean target data source and then use Step Functions for advanced transformation. After perform the ETL transforms and store the data in S3 target location.

Details：see Project_part3_V3

> *About Databrew*
> * visual data preparation tool 
> * enrich, clean, and normalize data without writing any line of code.

## Step 4 ETL job in Glue Job
AWS Glue provides some great built-in transformation. Glue automatically generates the code for ETL job according to our selected source, sink, and transformation in pyspark or python based on choice. 

*About Glue*
* serverless ETL tool 
* on a fully managed Apache Spark environment (speed and power)
* pay only for the queries that you run

## Step 5 Automating ETL


## Step 6 Modelling
Details see [train.r](/train.r)

## Project Notes 

### ETL Pipeline
why choose glue?
* As the solution for a serverless service, Glue process data from multiple sources across the company, including files and databases.
* Glue strives to address both data setup and processing in one place with minimal infrastructure setup.
* The Glue data catalog can make both file-based and traditional data sources available to Glue jobs, including schema detection through crawlers. It can share a Hive metastore with AWS Athena, a convenient feature for existing Athena users.
* To run jobs that process source data, Glue can use a Python shell or Spark. When Glue jobs use Spark, a Spark cluster is automatically spun up as soon as a job is run. Instead of manually configuring and managing Spark clusters on EC2 or EMR, Glue handles that for you nearly invisibly.
* The default timeout of glue is two days unlike lambda's max of 15 minutes. This means that Glue jobs can be used essentially like a Lambda for jobs that were too long or too unpredictable. 

### Recommandation Engine
Sample Dataset: over 3M grocery orders from more than 200,000 users

Goal: use transactional(historic) data to develop models that predict which products a user will 
* buy again, or
* try for the first time, or
* add to their cart next during a session

Primary Key to predict user behaviour: 
* user_id
* product_id

Factors to effect user behaviour 
1. user (user_feature_1, user_feature_2)
2. product (prd_features)
3. preference = user + product (up_features)
> These 3 factors are (Modelling Foundation), which is established in Step 3, finally exported as data.csv