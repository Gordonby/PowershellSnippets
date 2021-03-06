SUB="PseudoProd"
RG="MinecraftBedrock"
LOC="uksouth"
STOR="minecaftbedrock555"
CONT="minecraftbedrockaci"
WORLD="byers-mine-world"

az account set -s $SUB

az group create --name $RG --location $LOC

az storage account create \
    --resource-group $RG \
    --name $STOR \
    --kind StorageV2 \
    --sku Standard_ZRS \
    --enable-large-file-share \
    --output none

KEY=$(az storage account keys list -g $RG -n $STOR --query [0].value -o tsv)

az storage share create \
    --account-name $STOR \
    --name minecraftdata \
    --account-key $KEY \
    --quota 1024 \
    --output none

az container create \
    --resource-group $RG \
    --name $CONT \
    --image itzg/minecraft-bedrock-server:latest \
    --dns-name-label $WORLD \
    --ports 19132 \
    --protocol UDP \
    --azure-file-volume-account-name $STOR \
    --azure-file-volume-account-key $KEY \
    --azure-file-volume-share-name minecraftdata \
    --azure-file-volume-mount-path /data \
    --environment-variables \
        'EULA'='TRUE' \
        'GAMEMODE'='survival' \
        'DIFFICULTY'='peaceful'

FQDN=$(az container show -n $CONT -g $RG --query ipAddress.fqdn -o tsv)

echo $FQDN