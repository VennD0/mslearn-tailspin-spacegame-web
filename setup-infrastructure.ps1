# Setup Infrastructure for Multistage Pipeline

Write-Host "Setting up infrastructure for multistage pipeline demo..." -ForegroundColor Cyan

# Step 1: Check Azure Login
Write-Host "`nStep 1: Checking Azure Login..." -ForegroundColor Yellow
try {
    $account = az account show --query name -o tsv 2>$null
    if ($account) {
        Write-Host "SUCCESS: Logged in as: $account" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Not logged in. Please run: az login" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "ERROR: Azure CLI not found. Please install and login first." -ForegroundColor Red
    exit 1
}

# Step 2: Create Resource Group
Write-Host "`nStep 2: Creating Resource Group..." -ForegroundColor Yellow
$resourceGroup = "rg-tailspin-demo"
$location = "eastus"

$rgExists = az group exists --name $resourceGroup
if ($rgExists -eq "true") {
    Write-Host "SUCCESS: Resource group already exists" -ForegroundColor Green
} else {
    Write-Host "Creating resource group: $resourceGroup"
    az group create --name $resourceGroup --location $location
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: Resource group created" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Failed to create resource group" -ForegroundColor Red
        exit 1
    }
}

# Step 3: Create App Services
Write-Host "`nStep 3: Creating App Services..." -ForegroundColor Yellow

Write-Host "Creating UAT App Service Plan..."
az appservice plan create --name "tailspin-uat-plan" --resource-group $resourceGroup --sku F1 --location $location

Write-Host "Creating UAT Web App..."
az webapp create --name "tailspin-uat-webapp" --resource-group $resourceGroup --plan "tailspin-uat-plan" --runtime "DOTNETCORE:8.0"

Write-Host "Creating Production App Service Plan..."
az appservice plan create --name "tailspin-prod-plan" --resource-group $resourceGroup --sku S1 --location $location

Write-Host "Creating Production Web App..."
az webapp create --name "tailspin-prod-webapp" --resource-group $resourceGroup --plan "tailspin-prod-plan" --runtime "DOTNETCORE:8.0"

Write-Host "Creating Staging Slot..."
az webapp deployment slot create --name "tailspin-prod-webapp" --resource-group $resourceGroup --slot "staging"

Write-Host "`nSUCCESS: Infrastructure created!" -ForegroundColor Green

# Display Configuration
Write-Host "`n" + "="*60 -ForegroundColor Cyan
Write-Host "PIPELINE CONFIGURATION" -ForegroundColor Cyan
Write-Host "="*60 -ForegroundColor Cyan

Write-Host "`nUpdate your pipeline variables with these values:"
Write-Host ""
Write-Host "variables:" -ForegroundColor White
Write-Host "  azureServiceConnection: 'azure-service-connection'  # Create this in Azure DevOps" -ForegroundColor Yellow
Write-Host "  uatWebAppName: 'tailspin-uat-webapp'" -ForegroundColor Green
Write-Host "  prodWebAppName: 'tailspin-prod-webapp'" -ForegroundColor Green
Write-Host "  resourceGroupName: 'rg-tailspin-demo'" -ForegroundColor Green

Write-Host "`nApp URLs:" -ForegroundColor Cyan
Write-Host "  UAT: https://tailspin-uat-webapp.azurewebsites.net" -ForegroundColor White
Write-Host "  Production: https://tailspin-prod-webapp.azurewebsites.net" -ForegroundColor White
Write-Host "  Staging: https://tailspin-prod-webapp-staging.azurewebsites.net" -ForegroundColor White

Write-Host "`nNEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Create Service Connection in Azure DevOps Project Settings" -ForegroundColor White
Write-Host "2. Create Environments: UAT, Production-Staging, Production" -ForegroundColor White
Write-Host "3. Update pipeline variables with the values above" -ForegroundColor White
Write-Host "4. Run your multistage pipeline!" -ForegroundColor White

Write-Host "`nSetup completed successfully!" -ForegroundColor Green