# Complete Setup Script for Multistage Pipeline Demo

Write-Host "🚀 Setting up Multistage Pipeline Demo..." -ForegroundColor Cyan

# Step 1: Login to Azure
Write-Host "`n1️⃣ Azure Login" -ForegroundColor Yellow
try {
    $account = az account show --query name -o tsv 2>$null
    if ($account) {
        Write-Host "✅ Already logged in as: $account" -ForegroundColor Green
    } else {
        Write-Host "🔐 Please login to Azure..."
        az login
    }
} catch {
    Write-Host "🔐 Please login to Azure..."
    az login
}

# Step 2: Create Resource Group
Write-Host "`n2️⃣ Creating Resource Group" -ForegroundColor Yellow
$resourceGroup = "rg-tailspin-demo"
$location = "eastus"

$rgExists = az group exists --name $resourceGroup
if ($rgExists -eq "true") {
    Write-Host "✅ Resource group '$resourceGroup' already exists" -ForegroundColor Green
} else {
    Write-Host "🏗️ Creating resource group '$resourceGroup'..."
    az group create --name $resourceGroup --location $location
    Write-Host "✅ Resource group created" -ForegroundColor Green
}

# Step 3: Deploy Infrastructure
Write-Host "`n3️⃣ Deploying Infrastructure" -ForegroundColor Yellow

# Check if we have the Bicep file locally
if (Test-Path "infra/simple-demo.bicep") {
    Write-Host "🏗️ Deploying App Services with deployment slots..."
    $deployResult = az deployment group create `
        --resource-group $resourceGroup `
        --template-file "infra/simple-demo.bicep" `
        --parameters appNamePrefix=tailspin-demo `
        --query "properties.outputs" -o json
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Infrastructure deployed successfully" -ForegroundColor Green
        
        # Parse outputs
        $outputs = $deployResult | ConvertFrom-Json
        Write-Host "`n📋 Deployment Results:" -ForegroundColor Cyan
        Write-Host "  UAT Web App: $($outputs.uatWebAppName.value)" -ForegroundColor White
        Write-Host "  Production Web App: $($outputs.prodWebAppName.value)" -ForegroundColor White
        Write-Host "  UAT URL: $($outputs.uatUrl.value)" -ForegroundColor White
        Write-Host "  Production URL: $($outputs.prodUrl.value)" -ForegroundColor White
        Write-Host "  Staging URL: $($outputs.stagingUrl.value)" -ForegroundColor White
        
        # Save outputs for pipeline configuration
        $pipelineConfig = @{
            uatWebAppName = $outputs.uatWebAppName.value
            prodWebAppName = $outputs.prodWebAppName.value
            resourceGroupName = $resourceGroup
        }
        $pipelineConfig | ConvertTo-Json | Out-File "pipeline-config.json"
        Write-Host "`n💾 Pipeline configuration saved to 'pipeline-config.json'" -ForegroundColor Green
        
    } else {
        Write-Host "❌ Infrastructure deployment failed" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "⚠️ Bicep template not found. Creating simple infrastructure manually..." -ForegroundColor Yellow
    
    # Create App Service Plans
    Write-Host "Creating UAT App Service Plan..."
    az appservice plan create --name "tailspin-demo-uat-plan" --resource-group $resourceGroup --sku F1 --is-linux false
    
    Write-Host "Creating Production App Service Plan..."
    az appservice plan create --name "tailspin-demo-prod-plan" --resource-group $resourceGroup --sku S1 --is-linux false
    
    # Create Web Apps
    Write-Host "Creating UAT Web App..."
    az webapp create --name "tailspin-demo-uat-webapp" --resource-group $resourceGroup --plan "tailspin-demo-uat-plan" --runtime "DOTNETCORE:8.0"
    
    Write-Host "Creating Production Web App..."
    az webapp create --name "tailspin-demo-prod-webapp" --resource-group $resourceGroup --plan "tailspin-demo-prod-plan" --runtime "DOTNETCORE:8.0"
    
    # Create Staging Slot
    Write-Host "Creating Staging Slot..."
    az webapp deployment slot create --name "tailspin-demo-prod-webapp" --resource-group $resourceGroup --slot "staging"
    
    Write-Host "✅ Infrastructure created manually" -ForegroundColor Green
    
    $pipelineConfig = @{
        uatWebAppName = "tailspin-demo-uat-webapp"
        prodWebAppName = "tailspin-demo-prod-webapp"
        resourceGroupName = $resourceGroup
    }
    $pipelineConfig | ConvertTo-Json | Out-File "pipeline-config.json"
}

# Step 4: Instructions for Pipeline Setup
Write-Host "`n4️⃣ Pipeline Configuration" -ForegroundColor Yellow
Write-Host "📝 Update your pipeline variables with these values:" -ForegroundColor Cyan

if (Test-Path "pipeline-config.json") {
    $config = Get-Content "pipeline-config.json" | ConvertFrom-Json
    Write-Host ""
    Write-Host "variables:" -ForegroundColor White
    Write-Host "  azureServiceConnection: 'azure-service-connection'  # ⚠️ Update this" -ForegroundColor Yellow
    Write-Host "  uatWebAppName: '$($config.uatWebAppName)'" -ForegroundColor Green
    Write-Host "  prodWebAppName: '$($config.prodWebAppName)'" -ForegroundColor Green
    Write-Host "  resourceGroupName: '$($config.resourceGroupName)'" -ForegroundColor Green
}

Write-Host "`n5️⃣ Next Steps:" -ForegroundColor Yellow
Write-Host "1. Create Service Connection in Azure DevOps:" -ForegroundColor White
Write-Host "   - Go to Project Settings → Service connections" -ForegroundColor Gray
Write-Host "   - Create 'Azure Resource Manager' connection" -ForegroundColor Gray
Write-Host "   - Name it 'azure-service-connection'" -ForegroundColor Gray

Write-Host "`n2. Create Environments in Azure DevOps:" -ForegroundColor White
Write-Host "   - Go to Pipelines → Environments" -ForegroundColor Gray
Write-Host "   - Create: UAT, Production-Staging, Production" -ForegroundColor Gray

Write-Host "`n3. Update pipeline variables and run!" -ForegroundColor White

Write-Host "`n🎉 Setup complete! Your infrastructure is ready for the pipeline." -ForegroundColor Green