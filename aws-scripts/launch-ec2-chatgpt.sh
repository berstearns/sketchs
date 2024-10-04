#!/bin/bash

# Function to get available key pairs
get_key_pair() {
  echo "Fetching available key pairs..."
  local KEY_NAMES=$(aws ec2 describe-key-pairs --query 'KeyPairs[*].KeyName' --output text)

  if [ -z "$KEY_NAMES" ]; then
    echo "No key pairs found. Please create one in the AWS console."
    exit 1
  fi

  echo "Available key pairs:"
  select KEY_NAME in $KEY_NAMES; do
    if [ -n "$KEY_NAME" ]; then
      echo "Selected Key Pair: $KEY_NAME"
      break
    else
      echo "Invalid selection, please try again."
    fi
  done
}

# Function to get available security groups
get_security_group() {
  echo "Fetching available security groups..."
  local SECURITY_GROUPS=$(aws ec2 describe-security-groups --query 'SecurityGroups[*].GroupId' --output text)

  if [ -z "$SECURITY_GROUPS" ]; then
    echo "No security groups found. Please create one in the AWS console."
    exit 1
  fi

  echo "Available security groups:"
  select SECURITY_GROUP in $SECURITY_GROUPS; do
    if [ -n "$SECURITY_GROUP" ]; then
      echo "Selected Security Group: $SECURITY_GROUP"
      break
    else
      echo "Invalid selection, please try again."
    fi
  done
}

# Function to launch an EC2 instance
launch_instance() {
  local AMI_ID="ami-0c38b837cd80f13bb" # Example AMI ID for Amazon Linux 2, change as needed
  local INSTANCE_TYPE="t2.micro"
  local SUBNET_ID="your-subnet-id" # Optional: Specify your subnet ID if needed

  # --subnet-id $SUBNET_ID \
  # eu-west-1
  INSTANCE_ID=$(aws ec2 run-instances \
    --region us-east-1 \
    --image-id $AMI_ID \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-group-ids $SECURITY_GROUP \
    --query 'Instances[0].InstanceId' \
    --output text)

  # Check if the instance was successfully created
  if [ -z "$INSTANCE_ID" ]; then
    echo "Failed to launch EC2 instance"
    exit 1
  else
    echo "Launched EC2 instance with ID: $INSTANCE_ID"
  fi

  # Wait until the instance is in 'running' state
  aws ec2 wait instance-running --instance-ids $INSTANCE_ID
}

# Function to retrieve the public IP of the instance
get_public_ip() {
  PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

  if [ -z "$PUBLIC_IP" ]; then
    echo "Failed to retrieve public IP"
  else
    echo "EC2 instance is up and running. Public IP: $PUBLIC_IP"
  fi
}

# Main function to orchestrate the script
main() {
  get_key_pair
  get_security_group
  launch_instance
  get_public_ip
}

# Run the main function
main
