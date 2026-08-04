# Serverless Machine Learning Pipeline

# What is this project:

This project is an automated system that listens for audio files, converts the speech into text, translates that text into Spanish, and figures out if the speaker sounded positive or negative.

The entire process runs on "Serverless" technology. This means there are no servers running in the background. The system only wakes up when you upload a file, does the hard work using Artificial Intelligence, and then goes back to sleep.

# How It Works (The Data Journey):

The Upload (Amazon S3):
You upload an audio file (like an .mp3) into a cloud storage folder called an S3 Bucket.

The Alarm (AWS Lambda):
The moment the file is uploaded, an alarm rings. This wakes up a small piece of code called a Lambda function.

Speech-to-Text (Amazon Transcribe):
The Lambda function hands the audio file to Amazon Transcribe (an AI service). Transcribe listens to the audio, types out the English words into a text file, and saves it.

The Translation & Sentiment (Amazon Translate & Comprehend):
A second Lambda function wakes up, reads the new text file, and sends the text to two more AI services:

Amazon Translate: Converts the English text into Spanish.

Amazon Comprehend: Analyzes the mood of the text (Positive, Negative, or Neutral).

The Final Result (Amazon DynamoDB):
The final translated text and the mood score are bundled together and saved permanently into a fast database called DynamoDB.

# Tech Stack Used:

Infrastructure as code: Terraform 

Storage & Database: Amazon S3, Amazon DynamoDB

Compute: AWS Lambda (Python)

AI & Machine Learning: Amazon Transcribe, Amazon Translate, Amazon Comprehend

# How to Test the Pipeline:

Clone this repository 
 git clone [https://github.com/joshijay45/serverless-ml-pipeline.git]
  
Run terraform apply to build the infrastructure.

Open the AWS Console and upload an .mp3 file of someone speaking English into the "Input" S3 bucket.

Wait about 60 seconds.

Open your DynamoDB table in the AWS Console to see the original text, the Spanish translation, and the Sentiment score automatically appear!