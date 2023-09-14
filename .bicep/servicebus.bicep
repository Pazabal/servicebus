//BEGIN Params
@description('Name of the Service Bus namespace')
param serviceBusNamespaceName string = 'serviceBusNamespace5485'
param diagnosticSettingsName string = 'diagnosticSettings5656'
param DefenderforSBName string = 'DefenderforSB'

@description('The messaging tier for service Bus namespace')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])

param servicebus_sku string = 'Premium' // Default SKU here

@description('Set the premium partitions count as needed')
param servicebus_premiumMessagingPartitions int = 1 

@description('Location for all resources.')
param location string = resourceGroup().location
// END Params

// BEGIN SB Resource
resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2018-01-01-preview' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    capacity: int
    name: servicebus_sku
    tier: servicebus_sku
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {} // Service Principal selected for encryption
  }
  properties: {
    encryption: {
      keySource: 'Microsoft.KeyVault'
      keyVaultProperties: [
        {
          identity: {
            userAssignedIdentity: 'string' // Service Principal selected for encryption	
          }
          keyName: 'string' // Name of the Key from KeyVault	
          keyVaultUri: 'string' // Uri of KeyVault	
          keyVersion: 'string' // Version of KeyVault	
        }
      ]
      requireInfrastructureEncryption: true
    }
    minimumTlsVersion: '1.2' // Communication between a client application and an Azure Service Bus namespace is encrypted using Transport Layer Security (TLS). TLS is a standard cryptographic protocol that ensures privacy and data integrity between clients and services over the Internet. Azure Service Bus supports choosing a specific TLS version for namespaces. Currently Azure Service Bus uses TLS 1.2 on public endpoints by default, but TLS 1.0 and TLS 1.1 are still supported for backward compatibility.
    premiumMessagingPartitions: servicebus_sku == 'Premium' ? servicebus_premiumMessagingPartitions : null
    privateEndpointConnections: [
      {
        properties: {
          privateEndpoint: {
            id: 'string' // Target sub-resource: namespace from: https://learn.microsoft.com/en-us/azure/templates/microsoft.servicebus/namespaces/privateendpointconnections?pivots=deployment-language-bicep
          }
          privateLinkServiceConnectionState: { // 	Details about the state of the connection.
            description: 'Connection state approved.'
            status: 'Approved'
          }
          provisioningState: 'Succeeded' // 	Provisioning state of the Private Endpoint Connection.
        }
      }
    ]
  }
}
// END SB Resource

//BEGIN Defender for SB
resource symbolicname 'Microsoft.Security/advancedThreatProtectionSettings@2019-01-01' = {
  name: DefenderforSBName
  scope: serviceBusNamespace
  properties: {
    isEnabled: true
  }
}
//END Defender for SB

// BEGIN DS Resource
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: serviceBusNamespace
  properties: {
    // eventHubAuthorizationRuleId: 'string'
    // eventHubName: 'string'
    logAnalyticsDestinationType: 'AzureDiagnostics'
    logs: [
      {
        category: 'RuntimeAuditLogs'
        categoryGroup: 'AuditLogs'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
    // marketplacePartnerId: 'string'
    metrics: [
      {
        category: 'string'
        enabled: false
        retentionPolicy: {
          days: 0
          enabled: false
        }
        timeGrain: 'PT1H'
      }
    ]
    serviceBusRuleId: 'string'
    storageAccountId: 'string'
    workspaceId: 'workspaceId'
  }
}
// END DS Resource
