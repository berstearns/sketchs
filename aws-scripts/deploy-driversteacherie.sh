#!/bin/bash

# Variables
S3_BUCKET="s3://driverteacherie/"
FILE_PATH="./driverteacherie/website/deploy/index.html"
DISTRIBUTION_ID="E35CECDBH91J52"  # Replace with your CloudFront distribution ID

# Upload the file to S3
echo "Uploading $FILE_PATH to $S3_BUCKET..."
aws s3 cp $FILE_PATH $S3_BUCKET

if [ $? -eq 0 ]; then
    echo "File uploaded successfully."
else
    echo "Failed to upload file."
    exit 1
fi

# Create a CloudFront invalidation
echo "Creating CloudFront invalidation..."
INVALIDATION_OUTPUT=$(aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/index.html")

if [ $? -eq 0 ]; then
    echo "CloudFront invalidation created successfully."
    echo $INVALIDATION_OUTPUT
else
    echo "Failed to create CloudFront invalidation."
    exit 1
fi

