# Automated ETL Pipeline

## **Schedule based Architecture**
![](/Project_part5_v3/assets/Automated%20ETL%20Pipeline%20(Schedule%20Based).jpg)

High levels in this solution are as follows:

* Create target `Lambda functions` after `databrew` project and `Glue Job` script completion.
* Schedule AWS Lambda functions using `EventBridge`, which periodically trigger Lambda.


### Step 1 Create Lambda function 
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

### Step 2 Create EventBridge

Rule for trigger `Databrew` daily:
* name: databrew-etl-daily
* Rule type: schedule 
* pattern: rate expression (fixed rate of day)
* target: lambda functon (databrew-etl-daily)

Rule for trigger `Glue Job` daily:
* name: glue-job-etl-daily
* Rule type: schedule 
* pattern: rate expression (fixed rate of day)
* target: lambda functon (glue-job-etl-daily)

> Note:
>
> useful link for cron expression if needed future: https://crontab.guru/

![](/Project_part5_v3/assets/eb-lambda-log.png)

## **Trigger based Architecture**
![](/Project_part5_v3/assets/Automated%20ETL%20Pipeline%20(Trigger%20Based).jpg)

High levels in this solution are as follows:

* Create target `Lambda functions` after `databrew` project and `Glue Job` script completion.
* Configure `Event Notification` in S3 to invoke Lambda functions, the trigger invokes your function every time that an object is added to S3 bucket.

### Step 1 Create Lambda function 
Same as last the step in Schedule based Architecture but with S3 full access

### Step 2 Create Event Notification
Notification for trigger `Databrew`:
* name: databrew-etl
* Prefix: features/order_products_prior/ 
* Object creation: All object create events
* Destination: lambda functon (databrew-etl-daily)

Notification for trigger `Glue Job`:
* name: glue-job-etl
* Prefix: schedule 
* Object creation: All object create events
* Destination: lambda functon (glue-job-etl-daily)