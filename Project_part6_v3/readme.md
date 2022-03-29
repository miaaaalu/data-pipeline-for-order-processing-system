# Deploy the XGBoost on Segamaker 
Once DS team have trained, optimized and deployed the machine learning (ML) model, the next challenge is to host it in such a way that consumers can easily invoke and get predictions from it. 

`Amazon SageMaker` lets us host our model and provides an endpoint that consumers can invoke by a secure and simple API call using an HTTPS request. 

High level solutions in this part:
* Build end-points on `Segamaker` for hosting and deployment
* Invoking the `endpoint` from the web
    * Building `Lambda` Function 
    * Building `API Gateaway` (Rest API)
    * Invoke API Gateway with Lambda
* Test App 

![flow](/Project_part6_v3/assets/model-deployment.jpg)

For Modelling Building see: [xgboost-modelling.ipynb](/Project_part6_v3/xgboost-modelling.ipynb)

For Segamaker scripts with out put see: [modelling-deployment.ipynb](/Project_part6_v3/modelling-deployment.ipynb)

## Step 1 Creating the endpoint for a model on Segamaker 
Deploying the model to `SageMaker` hosting just requires a deploy call on the fitted model. This call takes an `instance count`, `instance type`. These are used when the resulting predictor is creatd on the endpoint.

 Pay attention to the instance type `ml.m4.xlarge` in below script where the model is being deployed, Amazon SageMaker doesn’t support automatic scaling for burstable instances such as t2. We would normally use the t2 instance types as part of development and light testing.
```py
# Import api
import boto3
runtime = boto3.Session().client('sagemaker-runtime')

# Deploy the pre-trained model 'xgb_attached' as an endpoint
xgb_predictor = xgb_attached.deploy(initial_instance_count = 1, instance_type = 'ml.m4.xlarge')

# get the endpoint name and take note
xgb_predictor.endpoint

# invoke the endpoint 'xgb_predictor.endpoint' AND interact with endpoint
response = runtime.invoke_endpoint(EndpointName = xgb_predictor.endpoint, 
                                                  ContentType = 'text/csv',
                                                  Body = '1,6.67578125,3418,209,0.595703125,514,10.0,11,57,11,1599,0.1498791297340854,1.2884770346494763,0.22388993120700437,9.017543859649123,0.017543859649122806,46,0.02127659574468085') # test script: featureing fields in the model

# response: the probablility of a user buy the product
response['Body'].read().decode('utf-8')
```

## Step 2 Building Lambda Function 
Once created the `endpoint`, we need a way to invoke it outside a notebook. The endpoint in this project expects .csv input.

Here, use `AWS Lambda` and `Amazon API Gateway` to format the input request and invoke the endpoint from the web. 

* IAM Role: full access to Sagemaker
* Function Name: imba-function
```py
import boto3

def lambda_handler(event, context):
    body = event['body']
    runtime = boto3.Session().client('sagemaker-runtime')

    # use the SageMaker runtime to invoke our endpoint, sending the review we were given
    response = runtime.invoke_endpoint(EndpointName = 'xgboost-2022-03-27-05-04-39-419',
                                       ContentType = 'text/csv',
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
```

## Step 3 Setting up API Gateway (Rest API)
**API Gateway Console**

After the stack has been created successfully, you can make a test call at API Gateway console
* Action: Create Method -- POST 
* Integration type: Lambda Function (imba_xgboost)
* Deploy API

```powershell
! Don't copy invoke URL at this step
```

**Lambda Console**
* Add Triggers and invoke with the API (Security: open)
* Copy API URL: https://********.execute-api.ap-southeast-2.amazonaws.com/Test/imba_xgboost

## Step 4 Setting up API Gateway (Rest API)
Replace the ACTION URL in [index.html](/Project_part6_v3/index.html) with the API URL

## Step 5 Hosting a Static Websites on AWS S3 and Testing
Create a new S3 bucket: 
* Name: `imba-web-page-test`
* Untick `Block all public access`
* upload [index.html](/Project_part6_v3/index.html) file to S3 bucket 
* upload [error.html](/Project_part6_v3/error.html) to S3 bucket
* Enabling `static website hosting` under Properties tab
* Editing `Bucket Policy` under Permission tab for public access. Replace default script with [policy.json](/Project_part6_v3/policy.json)

![image](/Project_part6_v3/assets/static-page.png)

## Useful Link 
[Load test and optimize an Amazon SageMaker endpoint using automatic scaling
](https://aws.amazon.com/blogs/machine-learning/load-test-and-optimize-an-amazon-sagemaker-endpoint-using-automatic-scaling/)