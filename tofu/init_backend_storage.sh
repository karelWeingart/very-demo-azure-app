#!/bin/bash
# Creates a blob storage in azure subscription
# Takes one param - region code.

RESOURCE_GROUP_NAME=tfstate
STORAGE_ACCOUNT_NAME=tfstate$RANDOM
CONTAINER_NAME=tfstate
REGION=$1
SKU=Standard_LRS
ENCRYPTION_SERVICES=blob

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $REGION

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku $SKU --encryption-services $ENCRYPTION_SERVICES

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME