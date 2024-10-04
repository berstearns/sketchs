#!/bin/bash

# Prompt for domain name
DOMAIN_NAME="bernardostearns.com"


# Request the SSL certificate from AWS ACM
echo "Requesting SSL certificate for $DOMAIN_NAME..."
CERTIFICATE_ARN=$(aws acm request-certificate \
    --domain-name $DOMAIN_NAME \
    --validation-method DNS \
    --query CertificateArn --output text)

if [ $? -eq 0 ]; then
    echo "SSL certificate requested successfully. Certificate ARN: $CERTIFICATE_ARN"
else
    echo "Failed to request SSL certificate."
    exit 1
fi

# Get the DNS validation options
echo "Retrieving DNS validation information..."
VALIDATION_OPTIONS=$(aws acm describe-certificate \
    --certificate-arn $CERTIFICATE_ARN \
    --query "Certificate.DomainValidationOptions[0].ResourceRecord" --output json)

if [ $? -eq 0 ]; then
    echo "DNS validation information retrieved successfully."
    echo "Validation details:"
    echo $VALIDATION_OPTIONS | jq .
else
    echo "Failed to retrieve DNS validation information."
    exit 1
fi

echo ""
echo "Please add the following DNS record to your domain's DNS settings to validate your domain:"
echo "Name: $(echo $VALIDATION_OPTIONS | jq -r .Name)"
echo "Type: $(echo $VALIDATION_OPTIONS | jq -r .Type)"
echo "Value: $(echo $VALIDATION_OPTIONS | jq -r .Value)"

echo ""
echo "After adding the DNS record, the certificate will be validated automatically."

echo "You can check the validation status using the following command:"
echo "aws acm describe-certificate --certificate-arn $CERTIFICATE_ARN --query 'Certificate.DomainValidationOptions[0].ValidationStatus'"

