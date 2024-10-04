#!/bin/bash

# Function to list all available AMIs
list_amis() {
  # Optional: Set filters to narrow down the list
  echo "Do you want to filter the AMIs by owner or name? (y/n)"
  read FILTER_CHOICE

  if [ "$FILTER_CHOICE" == "y" ]; then
    echo "Enter the AMI owner ID (leave blank for all owners):"
    read OWNER_ID

    echo "Enter a name filter (use wildcards like * for partial matches, leave blank for all names):"
    read NAME_FILTER

    if [ -z "$OWNER_ID" ] && [ -z "$NAME_FILTER" ]; then
      echo "No filters applied. Listing all AMIs."
      aws ec2 describe-images --query 'Images[*].[ImageId,Name,OwnerId,CreationDate]' --output table
    elif [ -z "$OWNER_ID" ]; then
      aws ec2 describe-images --filters "Name=name,Values=$NAME_FILTER" --query 'Images[*].[ImageId,Name,OwnerId,CreationDate]' --output table
    elif [ -z "$NAME_FILTER" ]; then
      aws ec2 describe-images --owners "$OWNER_ID" --query 'Images[*].[ImageId,Name,OwnerId,CreationDate]' --output table
    else
      aws ec2 describe-images --owners "$OWNER_ID" --filters "Name=name,Values=$NAME_FILTER" --query 'Images[*].[ImageId,Name,OwnerId,CreationDate]' --output table
    fi
  else
    echo "Listing all AMIs."
    aws ec2 describe-images --query 'Images[*].[ImageId,Name,OwnerId,CreationDate]' --output table
  fi
}

# Example of how to call the function
list_amis
