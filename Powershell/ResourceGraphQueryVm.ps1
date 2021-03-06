﻿# Install the Resource Graph module from PowerShell Gallery
Install-Module -Name Az.ResourceGraph

# Connect to Azure
Connect-AzAccount
Select-AzSubscription "subname"

# Filter to the right subscriptions
$subscriptions = Get-AzSubscription | ? {$_.name -like "Contoso*"} | select -ExpandProperty Id 

# Compose query
$query="where type == 'microsoft.compute/virtualmachines' |
where tags.environment == 'dev' |
project subscriptionId, resourceGroup, name, properties.hardwareProfile.vmSize, properties.licenseType"

# Run query
Search-AzGraph -Query $query -Subscription $subscriptions -First 5000
