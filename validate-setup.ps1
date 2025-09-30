# Quick Validation Script
# Run this after deploying infrastructure to test everything

Write-Host "🔍 Validating Azure Infrastructure..." -ForegroundColor Cyan

# Check if logged into Azure
try {
    $account = az account show --query name -o tsv
    Write-Host "✅ Logged into Azure as: $account" -ForegroundColor Green
} catch {
    Write-Host "❌ Not logged into Azure. Run 'az login' first." -ForegroundColor Red
    exit 1
}

# Check resource group
$rgExists = az group exists --name "rg-tailspin-demo"
if ($rgExists -eq "true") {
    Write-Host "✅ Resource group 'rg-tailspin-demo' exists" -ForegroundColor Green
} else {
    Write-Host "❌ Resource group 'rg-tailspin-demo' not found" -ForegroundColor Red
    Write-Host "   Run: az group create --name rg-tailspin-demo --location eastus" -ForegroundColor Yellow
}

# Check if web apps exist
$webApps = az webapp list --resource-group "rg-tailspin-demo" --query "[].name" -o tsv
if ($webApps) {
    Write-Host "✅ Found web apps:" -ForegroundColor Green
    $webApps | ForEach-Object { Write-Host "   - $_" -ForegroundColor White }
    
    # Test UAT endpoint
    $uatApp = $webApps | Where-Object { $_ -like "*uat*" }
    if ($uatApp) {
        $uatUrl = "https://$uatApp.azurewebsites.net"
        Write-Host "🌐 Testing UAT endpoint: $uatUrl" -ForegroundColor Cyan
        try {
            $response = Invoke-WebRequest -Uri $uatUrl -Method GET -TimeoutSec 10
            Write-Host "✅ UAT app is responding (HTTP $($response.StatusCode))" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  UAT app not yet responding (this is normal if just deployed)" -ForegroundColor Yellow
        }
    }
    
    # Test Production endpoint
    $prodApp = $webApps | Where-Object { $_ -like "*prod*" }
    if ($prodApp) {
        $prodUrl = "https://$prodApp.azurewebsites.net"
        Write-Host "🌐 Testing Production endpoint: $prodUrl" -ForegroundColor Cyan
        try {
            $response = Invoke-WebRequest -Uri $prodUrl -Method GET -TimeoutSec 10
            Write-Host "✅ Production app is responding (HTTP $($response.StatusCode))" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  Production app not yet responding (this is normal if just deployed)" -ForegroundColor Yellow
        }
        
        # Check staging slot
        $stagingUrl = $prodUrl.Replace(".azurewebsites.net", "-staging.azurewebsites.net")
        Write-Host "🌐 Testing Staging slot: $stagingUrl" -ForegroundColor Cyan
        try {
            $response = Invoke-WebRequest -Uri $stagingUrl -Method GET -TimeoutSec 10
            Write-Host "✅ Staging slot is responding (HTTP $($response.StatusCode))" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  Staging slot not yet responding (this is normal if just deployed)" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "❌ No web apps found in resource group" -ForegroundColor Red
    Write-Host "   Deploy infrastructure first using the Bicep template" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Update pipeline variables in azure-pipelines-multistage.yml" -ForegroundColor White
Write-Host "2. Create environments in Azure DevOps" -ForegroundColor White
Write-Host "3. Set up service connection" -ForegroundColor White
Write-Host "4. Run the pipeline!" -ForegroundColor White