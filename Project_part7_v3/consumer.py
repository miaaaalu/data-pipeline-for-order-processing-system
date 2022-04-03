import json
import re
import boto3

# Get the service resource.
dynamodb = boto3.resource('dynamodb')


table = dynamodb.Table('imba')

def lambda_handler(event, context):
    # TODO implement
    #print(event)
    #print(event[0]['payload']['value'])
    
    with table.batch_writer() as batch:
        for i in event:
            value = i['payload']['value']
            feature = re.search(r"feature=(.*)\,\ user_id",value ).group(1)
            user_id = re.search(r"user_id=(.*), product_id", value).group(1)
            product_id = re.search(r"product_id=(.*)\}", value).group(1)
            
            #print(user_id,product_id,feature)
            print('writting item to table')
            batch.put_item(
                Item={
                    'user_id': user_id,
                    'product_id': product_id,
                    'feature': feature
                }
            )
            break

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }