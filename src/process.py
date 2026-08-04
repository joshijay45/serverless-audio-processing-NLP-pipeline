import boto3, os, json, urllib.parse

s3, translate, comprehend = boto3.client('s3'), boto3.client('translate'), boto3.client('comprehend')
dynamodb = boto3.resource('dynamodb').Table(os.environ['DYNAMODB_TABLE'])

def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])

    # Fetch and parse the raw transcript JSON from S3
    obj = s3.get_object(Bucket=bucket, Key=key)
    transcript = json.loads(obj['Body'].read())['results']['transcripts'][0]['transcript']

    if not transcript.strip():
        print(f"Skipping ML processing for {key}: No speech detected in audio.")
        return "No speech detected"
    
    translated = translate.translate_text(Text=transcript, SourceLanguageCode='en', TargetLanguageCode=os.environ['TARGET_LANGUAGE'])['TranslatedText']
    sentiment = comprehend.detect_sentiment(Text=transcript, LanguageCode='en')['Sentiment']

     # Save Final Results
    job_id = key.replace('.json', '')
    result = {'JobId': job_id, 'OriginalText': transcript, 'TranslatedText': translated, 'Sentiment': sentiment}

    dynamodb.put_item(Item=result)
    s3.put_object(Bucket=os.environ['OUTPUT_BUCKET'], Key=f"{job_id}-summary.json", Body=json.dumps(result))

    return "ML Processing Complete"