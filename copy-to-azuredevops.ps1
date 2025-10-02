# PowerShell Script to Copy UseCase3 Files to Azure DevOps Project
# Run this script after cloning your Azure DevOps UseCase3 project

param(
    [Parameter(Mandatory=$true)]
    [string]$DestinationPath,
    
    [Parameter(Mandatory=$false)]
    [string]$SourcePath = "."
)

Write-Host "🔄 Copying UseCase3 files to Azure DevOps project..." -ForegroundColor Green
Write-Host "Source: $SourcePath" -ForegroundColor Gray
Write-Host "Destination: $DestinationPath" -ForegroundColor Gray
Write-Host ""

# Check if destination exists
if (-not (Test-Path $DestinationPath)) {
    Write-Host "❌ Destination path does not exist: $DestinationPath" -ForegroundColor Red
    exit 1
}

# Create directories if they don't exist
$directories = @("k8s", "infra")
foreach ($dir in $directories) {
    $destDir = Join-Path $DestinationPath $dir
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force
        Write-Host "✅ Created directory: $dir" -ForegroundColor Green
    }
}

# Files to copy
$filesToCopy = @(
    @{Source="Dockerfile"; Dest="Dockerfile"; Required=$true},
    @{Source=".dockerignore"; Dest=".dockerignore"; Required=$true},
    @{Source="azure-pipelines.yml"; Dest="azure-pipelines.yml"; Required=$true},
    @{Source="k8s\namespace.yaml"; Dest="k8s\namespace.yaml"; Required=$true},
    @{Source="k8s\deployment.yaml"; Dest="k8s\deployment.yaml"; Required=$true},
    @{Source="k8s\service.yaml"; Dest="k8s\service.yaml"; Required=$true},
    @{Source="k8s\ingress.yaml"; Dest="k8s\ingress.yaml"; Required=$false},
    @{Source="infra\aks-infrastructure.bicep"; Dest="infra\aks-infrastructure.bicep"; Required=$true},
    @{Source="README-UseCase3.md"; Dest="README-UseCase3.md"; Required=$false},
    @{Source="DEPLOYMENT-GUIDE-UseCase3.md"; Dest="DEPLOYMENT-GUIDE-UseCase3.md"; Required=$false},
    @{Source="INTEGRATION-GUIDE.md"; Dest="INTEGRATION-GUIDE.md"; Required=$false}
)

# Copy files
Write-Host "📁 Copying individual files:" -ForegroundColor Cyan
foreach ($file in $filesToCopy) {
    $sourcePath = Join-Path $SourcePath $file.Source
    $destPath = Join-Path $DestinationPath $file.Dest
    
    if (Test-Path $sourcePath) {
        Copy-Item $sourcePath $destPath -Force
        Write-Host "  ✅ $($file.Source) → $($file.Dest)" -ForegroundColor Green
    } elseif ($file.Required) {
        Write-Host "  ❌ Required file missing: $($file.Source)" -ForegroundColor Red
    } else {
        Write-Host "  ⚠️  Optional file missing: $($file.Source)" -ForegroundColor Yellow
    }
}

# Copy entire Tailspin.SpaceGame.Web directory
Write-Host ""
Write-Host "📁 Copying Tailspin.SpaceGame.Web application:" -ForegroundColor Cyan
$appSource = Join-Path $SourcePath "Tailspin.SpaceGame.Web"
$appDest = Join-Path $DestinationPath "Tailspin.SpaceGame.Web"

if (Test-Path $appSource) {
    if (Test-Path $appDest) {
        Remove-Item $appDest -Recurse -Force
        Write-Host "  🗑️  Removed existing Tailspin.SpaceGame.Web" -ForegroundColor Yellow
    }
    Copy-Item $appSource $appDest -Recurse -Force
    Write-Host "  ✅ Copied Tailspin.SpaceGame.Web application" -ForegroundColor Green
} else {
    Write-Host "  ❌ Tailspin.SpaceGame.Web directory not found!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🎉 File copy completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "1. Commit and push changes to Azure DevOps repository" -ForegroundColor White
Write-Host "2. Set up service connections in Azure DevOps:" -ForegroundColor White
Write-Host "   • Docker Registry: tailspin-acr-connection → tailspinacr2025" -ForegroundColor Gray
Write-Host "   • Kubernetes: tailspin-aks-connection → tailspin-aks-prod" -ForegroundColor Gray
Write-Host "3. Create/update Azure DevOps pipeline pointing to azure-pipelines.yml" -ForegroundColor White
Write-Host "4. Run the pipeline to deploy to AKS!" -ForegroundColor White
Write-Host ""

# Display file structure
Write-Host "📊 Copied file structure:" -ForegroundColor Cyan
Get-ChildItem $DestinationPath -Recurse -Name | ForEach-Object {
    if ($_ -like "*.yml" -or $_ -like "*.yaml" -or $_ -like "*.bicep" -or $_ -like "Dockerfile*" -or $_ -like "*.md") {
        Write-Host "  📄 $_" -ForegroundColor Gray
    } elseif ($_ -like "*/" -or (Get-Item (Join-Path $DestinationPath $_)).PSIsContainer) {
        Write-Host "  📁 $_" -ForegroundColor Blue
    }
} | Select-Object -First 20

if ((Get-ChildItem $DestinationPath -Recurse).Count -gt 20) {
    Write-Host "  ... and more files" -ForegroundColor Gray
}

Write-Host ""
Write-Host "✅ Ready for Azure DevOps pipeline deployment!" -ForegroundColor Green