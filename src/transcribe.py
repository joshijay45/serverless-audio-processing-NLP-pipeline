import boto3
import os 
import urllib.parse

transcribe = boto3.client('transcribe')

def lambda_handler(event, context):

    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])

    job_name = f"Job-{context.aws_request_id}"
    transcribe.start_transcription_job(
        TranscriptionJobName=job_name,
        Media={'MediaFileUri': f"s3://{bucket}/{key}"},
        LanguageCode='en-US',
        OutputBucketName=os.environ['TRANSCRIBE_BUCKET']
    )
    return f"Transcription started for {key}"
    