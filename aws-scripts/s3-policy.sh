#!/bin/bash
# Variables
BUCKET_NAME="driverteacherie"
IAM_ENTITY_NAME="bernardostearnsreisen" # Replace with your IAM user or role name
ENTITY_TYPE="user"                      # Change to "role" if attaching to an IAM role
POLICY_NAME='S3'$BUCKET_NAME'Policy'
REGION="us-east-1" # Adjust this to your desired AWS region

# JSON policy file content
read -r -d '' POLICY_DOCUMENT <<EOM
"Version": "2012-10-17",
{
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutBucketPolicy",
                "s3:PutBucketWebsite",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::$BUCKET_NAME",
                "arn:aws:s3:::$BUCKET_NAME/*"
            ]
        }
    ]
}
EOM

# Function to create a custom IAM policy
create_custom_policy() {
  echo "Creating custom IAM policy..."
  aws iam create-policy --policy-name $POLICY_NAME --policy-document "$POLICY_DOCUMENT"
}

# Function to attach policy to the IAM user or role
attach_policy_to_iam_entity() {
  POLICY_ARN="arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/$POLICY_NAME"

  if [ "$ENTITY_TYPE" = "user" ]; then
    echo "Attaching policy to IAM user..."
    aws iam attach-user-policy --policy-arn $POLICY_ARN --user-name $IAM_ENTITY_NAME
  elif [ "$ENTITY_TYPE" = "role" ]; then
    echo "Attaching policy to IAM role..."
    aws iam attach-role-policy --policy-arn $POLICY_ARN --role-name $IAM_ENTITY_NAME
  else
    echo "Invalid entity type. Must be 'user' or 'role'."
    exit 1
  fi
}

# Function to set bucket policy for public read access
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

# Main function to orchestrate the script
main() {
  create_custom_policy
  exit
  attach_policy_to_iam_entity
  set_bucket_policy
}

# Execute the script
main
