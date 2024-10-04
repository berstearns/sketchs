# #!/bin/bash
# DEFAULTVPCID="vpc-0a9f5fdde22b075d3"
# GROUPNAME="DRIVERTEACHERIE"
# aws ec2 create-security-group --group-name $GROUPNAME --description "My security group" --vpc-id $DEFAULTVPCID
# vpc-0b1643c307e1f38e3
# exit
# 
# KEYPAIRNAME="DRIVERTEACHERIE"
# aws ec2 create-key-pair --key-name $KEYPAIRNAME --query "$KEYPAIRNAME" --output text >$KEYPAIRNAME.pem
# 
# # Set the instance type
# INSTANCEOS="ami-0a2202cf4c36161a1"
# INSTANCETYPE="t2.micro"
# # Set the instance name
# INSTANCENAME="ec2-instance"
# 
# # Set the instance region
# REGION="us-east-1"
# 
# # Set the instance key pair
# KEYPAIR="ec2-key-pair"
# 
# # Set the instance security group
# SECURITYGROUP="ec2-security-group"
# 
# # aws ec2 run-instances --image-id ami-xxxxxxxx --count 1 --instance-type t2.micro --key-name MyKeyPair --security-group-ids sg-903004f8 --subnet-id subnet-6e7f829e
# 
#!/bin/bash

# Define variables
REGION="us-east-1"                   # Specify your preferred AWS region
INSTANCE_TYPE="t2.micro"              # Free-tier eligible instance type
AMI_ID="ami-0a49b025fffbbdac6"        # Ubuntu 22.04 LTS AMI (Free Tier eligible)
KEY_NAME="my-key-pair"                # Replace with your key pair name
SECURITY_GROUP="my-security-group"    # Security group name
TAG_NAME="MyUbuntuInstance"           # Tag for the instance

# Create a security group
echo "Creating a security group..."
SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --group-name $SECURITY_GROUP \
    --description "Security group for EC2" \
    --vpc-id $(aws ec2 describe-vpcs --query 'Vpcs[0].VpcId' --output text) \
    --region $REGION \
    --query 'GroupId' \
    --output text)

echo "Security group created with ID: $SECURITY_GROUP_ID"

# Add rules to the security group to allow SSH and HTTP access
echo "Adding rules to security group..."
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID \
    --protocol tcp --port 22 --cidr 0.0.0.0/0 --region $REGION

aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID \
    --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $REGION

# Launch the instance
echo "Launching EC2 instance..."
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-group-ids $SECURITY_GROUP_ID \
    --region $REGION \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$TAG_NAME}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "EC2 instance launched with ID: $INSTANCE_ID"

# Wait for the instance to be running
echo "Waiting for the instance to be in a 'running' state..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION
echo "Instance is now running!"

# Get the public IP of the instance
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text --region $REGION)

echo "EC2 instance public IP: $PUBLIC_IP"

# Display a message
echo "You can now SSH into the instance using: ssh -i $KEY_NAME.pem ubuntu@$PUBLIC_IP"
