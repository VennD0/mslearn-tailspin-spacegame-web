# Simple Setup Script for Multistage Pipeline Demo

Write-Host "🚀 Setting up Multistage Pipeline Demo..." -ForegroundColor Cyan

# Step 1: Check Azure Login
Write-Host "`n1. Checking Azure Login..." -ForegroundColor Yellow
try {
    $account = az account show --query name -o tsv 2>$null
    if ($account) {
        Write-Host "✅ Logged in as: $account" -ForegroundColor Green
    } else {
        Write-Host "❌ Not logged in. Run: az login" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Azure CLI not found or not logged in" -ForegroundColor Red
    Write-Host "Please install Azure CLI and run: az login" -ForegroundColor Yellow
    exit 1
}

# Step 2: Create Resource Group
Write-Host "`n2. Creating Resource Group..." -ForegroundColor Yellow
$resourceGroup = "rg-tailspin-demo"
$location = "eastus"

$rgExists = az group exists --name $resourceGroup
if ($rgExists -eq "true") {
    Write-Host "✅ Resource group exists" -ForegroundColor Green
} else {
    Write-Host "Creating resource group..."
    az group create --name $resourceGroup --location $location
    Write-Host "✅ Resource group created" -ForegroundColor Green
}

# Step 3: Create App Services
Write-Host "`n3. Creating App Services..." -ForegroundColor Yellow

# UAT App Service
Write-Host "Creating UAT App Service Plan..."
az appservice plan create --name "tailspin-uat-plan" --resource-group $resourceGroup --sku F1 --is-linux false --location $location

Write-Host "Creating UAT Web App..."
az webapp create --name "tailspin-uat-webapp" --resource-group $resourceGroup --plan "tailspin-uat-plan" --runtime "DOTNETCORE:8.0"

# Production App Service
Write-Host "Creating Production App Service Plan..."
az appservice plan create --name "tailspin-prod-plan" --resource-group $resourceGroup --sku S1 --is-linux false --location $location

Write-Host "Creating Production Web App..."
az webapp create --name "tailspin-prod-webapp" --resource-group $resourceGroup --plan "tailspin-prod-plan" --runtime "DOTNETCORE:8.0"

# Staging Slot
Write-Host "Creating Staging Slot..."
az webapp deployment slot create --name "tailspin-prod-webapp" --resource-group $resourceGroup --slot "staging"

Write-Host "✅ Infrastructure created successfully!" -ForegroundColor Green

# Step 4: Display Configuration
Write-Host "`n📋 Pipeline Configuration:" -ForegroundColor Cyan
Write-Host "Update your pipeline variables with:" -ForegroundColor Yellow
Write-Host ""
Write-Host "variables:" -ForegroundColor White
Write-Host "  azureServiceConnection: 'azure-service-connection'  # ⚠️ Create this in Azure DevOps" -ForegroundColor Yellow
Write-Host "  uatWebAppName: 'tailspin-uat-webapp'" -ForegroundColor Green
Write-Host "  prodWebAppName: 'tailspin-prod-webapp'" -ForegroundColor Green
Write-Host "  resourceGroupName: 'rg-tailspin-demo'" -ForegroundColor Green

Write-Host "`n🔗 App URLs:" -ForegroundColor Cyan
Write-Host "UAT: https://tailspin-uat-webapp.azurewebsites.net" -ForegroundColor White
Write-Host "Production: https://tailspin-prod-webapp.azurewebsites.net" -ForegroundColor White
Write-Host "Staging: https://tailspin-prod-webapp-staging.azurewebsites.net" -ForegroundColor White

Write-Host "`n🎯 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Create Service Connection in Azure DevOps" -ForegroundColor White
Write-Host "2. Create Environments: UAT, Production-Staging, Production" -ForegroundColor White
Write-Host "3. Update pipeline variables" -ForegroundColor White
Write-Host "4. Run the pipeline!" -ForegroundColor White

Write-Host "`n🎉 Setup complete!" -ForegroundColor Green