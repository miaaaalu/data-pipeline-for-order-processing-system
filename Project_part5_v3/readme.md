# Automated ETL Pipeline

## **Schedule based Architecture**
![](/Project_part5_v3/assets/scheduled-based-flow.jpg)

High levels in this solution are as follows:

* Create target Lambda functions after databrew project and Glue Job script completion.
* Schedule AWS Lambda functions using EventBridge, which periodically trigger databrew and Glue Job.


### Step 1 Create Lambda function 
Lambda function for `Glue Job`
* name: glue-job-etl-daily
* runtime: python 3.8
* IAM role: full access to Glue

```py
import boto3
glue= boto3.client('glue')
def lambda_handler(event, context):    
    response = glue.start_job_run(JobName='gluejob3.0')
```

Lambda function for `Databrew`
* name: databrew-etl-daily
* runtime: python 3.8
* IAM role: full access to Databrew

```py
import boto3
databrew= boto3.client('databrew')
def lambda_handler(event, context):    
    response = databrew.start_job_run(Name='user-features-2')
```

### Step 2 Create EventBridge

Rule for trigger `Glue Job` daily:
* name: glue-job-etl-daily
* Rule type: schedule 
* pattern: rate expression (fixed rate of day)
* target: lambda functon (glue-job-etl-daily)

Rule for trigger `Databrew` daily:
* name: databrew-job-etl-daily
* Rule type: schedule 
* pattern: rate expression (fixed rate of day)
* target: lambda functon (databrew-job-etl-daily)

> Note:
>
> useful link for cron expression if needed future: https://crontab.guru/

![](/Project_part5_v3/assets/eb-lambda-log.png)