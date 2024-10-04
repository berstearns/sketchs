#!/bin/bash

# Function to create a key pair
create_key_pair() {
  # Prompt for the key pair name
  echo "Enter a name for your new key pair:"
  read KEY_PAIR_NAME

  # Create the key pair
  echo "Creating key pair '$KEY_PAIR_NAME'..."
  aws ec2 create-key-pair --key-name $KEY_PAIR_NAME --query 'KeyMaterial' --output text >${KEY_PAIR_NAME}.pem

  # Check if the key pair was successfully created
  if [ $? -ne 0 ]; then
    echo "Failed to create key pair."
    exit 1
  fi

  # Set appropriate permissions on the private key file
  chmod 400 ${KEY_PAIR_NAME}.pem

  echo "Key pair '$KEY_PAIR_NAME' created and saved to '${KEY_PAIR_NAME}.pem'."
  echo "Please store this file securely, as this is your only copy of the private key."
}

# Example of how to call the function
create_key_pair
