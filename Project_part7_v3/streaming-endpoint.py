import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('your table name in dynamodb')


def lambda_handler(event, context):

    body = event['body']
    #print(event)
    user_id = body.split(',')[0]
    product_id = body.split(',')[1]
    
    response = table.get_item(Key={'user_id': user_id, 'product_id': product_id})
    print(response)
    body = response['Item']['feature']
    
    #exit()
    # The SageMaker runtime is what allows us to invoke the endpoint that we've created.
    runtime = boto3.Session().client('sagemaker-runtime')

    # Now we use the SageMaker runtime to invoke our endpoint, sending the review we were given
    response = runtime.invoke_endpoint(EndpointName = 'your-endpoint-name',# The name of the endpoint we created
                                       ContentType = 'text/csv',                 # The data format that is expected
                                       Body = body
                                       )

    # The response is an HTTP response whose body contains the result of our inference
    result = response['Body'].read().decode('utf-8')

    # Round the result so that our web app only gets '1' or '0' as a response.
    result = float(result)

    return {
        'statusCode' : 200,
        'headers' : { 'Content-Type' : 'text/plain', 'Access-Control-Allow-Origin' : '*' },
        'body' : str(result)
    }