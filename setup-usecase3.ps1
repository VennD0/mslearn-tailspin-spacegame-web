# UseCase 3: Docker + AKS Setup Script
# Deploys Azure Container Registry and Azure Kubernetes Service

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName = "rg-tailspin-aks",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "East US",
    
    [Parameter(Mandatory=$false)]
    [string]$NamePrefix = "tailspin",
    
    [Parameter(Mandatory=$false)]
    [string]$Environment = "prod"
)

Write-Host "🚀 Starting UseCase 3: Docker + AKS Infrastructure Deployment" -ForegroundColor Green
Write-Host ""

# Check if Azure CLI is installed and logged in
try {
    $azureAccount = az account show --query "name" -o tsv 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Please login to Azure CLI first: az login" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Azure CLI authenticated as: $azureAccount" -ForegroundColor Green
}
catch {
    Write-Host "❌ Azure CLI not found. Please install Azure CLI first." -ForegroundColor Red
    exit 1
}

# Create resource group
Write-Host ""
Write-Host "📦 Creating resource group: $ResourceGroupName" -ForegroundColor Yellow
az group create --name $ResourceGroupName --location $Location

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create resource group" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Resource group created successfully" -ForegroundColor Green

# Deploy infrastructure using Bicep
Write-Host ""
Write-Host "🏗️ Deploying AKS and ACR infrastructure..." -ForegroundColor Yellow

$deploymentName = "usecase3-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

az deployment group create `
    --resource-group $ResourceGroupName `
    --template-file "infra/aks-infrastructure.bicep" `
    --parameters namePrefix=$NamePrefix environment=$Environment `
    --name $deploymentName `
    --verbose

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Infrastructure deployment failed" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Infrastructure deployed successfully" -ForegroundColor Green

# Get deployment outputs
Write-Host ""
Write-Host "📋 Retrieving deployment information..." -ForegroundColor Yellow

$outputs = az deployment group show --resource-group $ResourceGroupName --name $deploymentName --query "properties.outputs" -o json | ConvertFrom-Json

$acrName = $outputs.acrName.value
$acrLoginServer = $outputs.acrLoginServer.value
$aksClusterName = $outputs.aksClusterName.value
$aksClusterFqdn = $outputs.aksClusterFqdn.value

Write-Host ""
Write-Host "🎉 UseCase 3 Infrastructure Deployment Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Deployment Summary:" -ForegroundColor Cyan
Write-Host "  Resource Group: $ResourceGroupName" -ForegroundColor White
Write-Host "  Location: $Location" -ForegroundColor White
Write-Host "  ACR Name: $acrName" -ForegroundColor White
Write-Host "  ACR Login Server: $acrLoginServer" -ForegroundColor White
Write-Host "  AKS Cluster Name: $aksClusterName" -ForegroundColor White
Write-Host "  AKS Cluster FQDN: $aksClusterFqdn" -ForegroundColor White
Write-Host ""

Write-Host "🔧 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Configure Azure DevOps service connections:" -ForegroundColor White
Write-Host "   • Docker Registry Service Connection for ACR" -ForegroundColor Gray
Write-Host "   • Kubernetes Service Connection for AKS" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Update pipeline variables:" -ForegroundColor White
Write-Host "   • Replace #{ACR_NAME}# with: $acrName" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Get AKS credentials (for local testing):" -ForegroundColor White
Write-Host "   az aks get-credentials --resource-group $ResourceGroupName --name $aksClusterName" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Test Docker build locally:" -ForegroundColor White
Write-Host "   docker build -t $acrLoginServer/tailspin/spacegame-web:latest ." -ForegroundColor Gray
Write-Host ""
Write-Host "5. Login to ACR (for local testing):" -ForegroundColor White
Write-Host "   az acr login --name $acrName" -ForegroundColor Gray
Write-Host ""

Write-Host "✅ Ready to run your Azure DevOps pipeline!" -ForegroundColor Green