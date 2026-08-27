# Serverless Machine Learning Pipeline

# What is this project?

I built this event-driven serverless pipeline to automatically process audio files. When you upload an audio file, the system transcribes the speech to text, translates it into Spanish, and performs sentiment analysis to see if the speaker sounded positive, negative, or neutral.

Because the entire architecture is serverless, there are no idle servers running in the background. The system only wakes up—and only costs money—when a file is actively being processed. Everything is provisioned using Terraform.

# How It Works (The Data Journey)

The Upload (Amazon S3):
You upload an audio file (like an .mp3) into an S3 Bucket.

The Trigger (AWS Lambda):
Dropping a file into the bucket triggers an S3 event. This instantly wakes up a Python-based Lambda function.

Speech-to-Text (Amazon Transcribe):
The Lambda function passes the audio file to Amazon Transcribe. Transcribe listens to the audio, generates an English text transcript, and saves it.

Translation & Sentiment (Amazon Translate & Comprehend):
A second Lambda function picks up the new text file and makes two API calls: one to Amazon Translate to convert the text to Spanish, and one to Amazon Comprehend to analyze the mood of the text.

The Final Result (Amazon DynamoDB):
The original text, the Spanish translation, and the sentiment score are bundled together and permanently saved into a DynamoDB table for easy querying.

# Tech Stack Used

Infrastructure as Code: Terraform

Storage & Database: Amazon S3, Amazon DynamoDB

Compute: AWS Lambda (Python / Boto3)

AI & Machine Learning: Amazon Transcribe, Amazon Translate, Amazon Comprehend

# How to Test the Pipeline

Clone this repository:
git clone https://github.com/joshijay45/serverless-ml-pipeline.git

Run terraform apply to build the infrastructure in your AWS account.

Open the AWS Console and upload an .mp3 file of someone speaking English into the generated "Input" S3 bucket.

Wait about 60 seconds for the ML services to finish processing.

Open your DynamoDB table in the AWS Console to see the original text, the Spanish translation, and the Sentiment score automatically appear.