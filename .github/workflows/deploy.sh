#!/bin/bash

# Log into Azure
az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID

# Set Azure subscription
az account set --subscription $AZURE_SUBSCRIPTION

# Deploy Bicep file
az deployment group create \
  --name servicebus \
  --resource-group $AZURE_RESOURCE_GROUP \
  --template-file ./.bicep/servicebus.json