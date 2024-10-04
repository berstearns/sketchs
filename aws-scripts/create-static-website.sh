#!/bin/bash
set -e
# Variables
BUCKET_NAME="driverteacherie"
WEBSITEFOLDER="./driverteacherie/website"
#"my-static-website-$(date +%s)"
INDEX_FILE=$WEBSITEFOLDER"/index.html"
CLOUDFRONT_COMMENT="Static website using S3 and CloudFront"
REGION="us-east-1" # You can change this to your desired region

# Function to create an index.html file
create_index_file() {
  echo "Creating index.html file..."
  cat <<EOT >$INDEX_FILE
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to My Static Website</title>
</head>
<body>
    <h1>Hello, World!</h1>
    <p>This is a simple static website hosted on AWS S3 and served via CloudFront.</p>
</body>
</html>
EOT
}

bucket_exists() {
  aws s3 ls "s3://$1" 2>&1 | grep -q 'NoSuchBucket'
}

# Function to create an S3 bucket and enable static website hosting
create_s3_bucket_if_not_exists() {
  if bucket_exists $BUCKET_NAME; then
    echo "Bucket $BUCKET_NAME does not exist. Creating it..."
    aws s3 mb s3://$BUCKET_NAME --region $REGION
  else
    echo "Bucket $BUCKET_NAME already exists. Skipping creation."
  fi
}

set_bucket_policy() {
  echo "Setting bucket policy to allow public read access..."
  aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "PublicReadGetObject",
                "Effect": "Allow",
                "Principal": "*",
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::'"$BUCKET_NAME"'/*"
            }
        ]
    }'
}

enable_s3_website() {
  echo "Enabling static website hosting on the S3 bucket..."
  aws s3 website s3://$BUCKET_NAME/ --index-document index.html
}

# Function to create a CloudFront distribution
create_cloudfront_distribution() {
  echo "Creating CloudFront distribution..."
  CLOUDFRONT_DIST_ID=$(aws cloudfront create-distribution \
    --origin-domain-name ${BUCKET_NAME}.s3.amazonaws.com \
    --default-root-object $INDEX_FILE \
    --query 'Distribution.Id' \
    --output text)

  echo "Waiting for CloudFront distribution to deploy..."
  aws cloudfront wait distribution-deployed --id $CLOUDFRONT_DIST_ID

  CLOUDFRONT_DOMAIN=$(aws cloudfront get-distribution \
    --id $CLOUDFRONT_DIST_ID \
    --query 'Distribution.DomainName' \
    --output text)
}

# Function to display the CloudFront domain
output_website_url() {
  echo "Website deployed successfully!"
  echo "Access your website at: https://$CLOUDFRONT_DOMAIN"
}

# Main function to orchestrate the script
main() {
  create_index_file
  create_s3_bucket_if_not_exists
  # set_bucket_policy
  # enable_s3_website
  # create_cloudfront_distribution
  # output_website_url
}

# Call the main function
main
