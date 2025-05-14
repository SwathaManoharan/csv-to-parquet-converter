import boto3
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
import io
import os

s3 = boto3.client('s3')
ses = boto3.client('ses')

DEST_BUCKET = os.environ['DEST_BUCKET']
EMAIL_TO = os.environ['SES_EMAIL_TO']

def lambda_handler(event, context):
    # Get object info
    bucket = event['Records'][0]['s3']['bucket']['name']
    key    = event['Records'][0]['s3']['object']['key']

    # Read CSV from S3
    response = s3.get_object(Bucket=bucket, Key=key)
    df = pd.read_csv(response['Body'])

    # Convert to Parquet
    buffer = io.BytesIO()
    table = pa.Table.from_pandas(df)
    pq.write_table(table, buffer)

    # Upload to destination S3
    new_key = key.replace(".csv", ".parquet")
    s3.put_object(Bucket=DEST_BUCKET, Key=new_key, Body=buffer.getvalue())

    # Send SES notification
    ses.send_email(
        Source=EMAIL_TO,
        Destination={'ToAddresses': [EMAIL_TO]},
        Message={
            'Subject': {'Data': 'CSV Converted to Parquet'},
            'Body': {'Text': {'Data': f'File {key} has been converted and uploaded to {DEST_BUCKET}'}}
        }
    )

    return {"status": "success"}
