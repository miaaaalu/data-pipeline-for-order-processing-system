# Data Streaming processing
![](/Project_part7_v3/asset/data%20streaming%20process.jpg)

The diagram above is a collection of workflows:
* Invoke `Lambda Producer Function`  to receive message in Kafka
* Translate consumed Kafka message to `Dynamodb` by using `Lambda Consumer Function`

## Step 1 Create Table in DynamoDb
* `Name`: streaming-table
* `Partition key`: user_id (String)
* `sort key`: product_id (String)

## Step 2 Create Cluster in Kafka
### Cluster
* `Cluster`: basic
* `Cloud`: AWS 

### Topic 
* `name`: streaming-topic
* `partitions`: 6 

### Schema
* [kafka-schema.json](/Project_part7_v3/kafka-schema.json)

### Data Integration
Producers API
* `Clients`: Python
* Create `API Key`. Take a note for `key`, `Secret`, `bootstrap.servers`, which will be used in Lambda Function(Producer)

Consumers API

There is a classy solution for this in “server full” mode — AWS Lambda Sink Connecter. Under the hood, the Confluent connector aggregates Kafka records into batches and sends them to the Lambda Consumer function.
* `Connectors`: AWS Lambda Sink
* `Topic`: streaming-topic
* `Kafka credentials`: Use an existing API key, which has been created in `Producers API`
* `Authentication`: create a user for Kafka in AWS
* `Lambda Function`: consumer
* `Data Format`: json
* `number of topic`: 1

## Step 3 Create Lambda Functions
### Producer Function 
* `runtime`: python 3.8
* `layer`: [confluent.zip](/Project_part7_v3/confluent.zip)
* `script`：[producer.py](/Project_part7_v3/producer.py)
* `iam role`: S3 full access

### Consumer Function
* `runtime`: python 3.8
* `script`：[consumer.py](/Project_part7_v3/consumer.py)
* `iam role`: DynamoDB FullAccess

### Streaming Function
* `runtime`: python 3.8
* `script`：[streaming-endpoint.py](/Project_part7_v3/streaming-endpoint.py)
* `iam role`: DynamoDB FullAccess, Sagemaker FullAccess
