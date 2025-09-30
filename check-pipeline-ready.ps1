# Pipeline Readiness Check
# Run this before creating your pipeline

Write-Host "🔍 Checking pipeline readiness..." -ForegroundColor Cyan

# Check if project file exists
$projectPath = "Tailspin.SpaceGame.Web/Tailspin.SpaceGame.Web.csproj"
if (Test-Path $projectPath) {
    Write-Host "✅ Project file found: $projectPath" -ForegroundColor Green
} else {
    Write-Host "❌ Project file not found: $projectPath" -ForegroundColor Red
    Write-Host "   Available files:" -ForegroundColor Yellow
    Get-ChildItem -Recurse -Filter "*.csproj" | Select-Object FullName
}

# Check pipeline files
Write-Host "`n📄 Available pipeline files:" -ForegroundColor Cyan
Get-ChildItem -Filter "azure-pipelines*.yml" | ForEach-Object {
    Write-Host "   ✅ $($_.Name)" -ForegroundColor Green
}

# Check if in git repository
try {
    $branch = git branch --show-current
    Write-Host "`n🌿 Current branch: $branch" -ForegroundColor Green
    
    $status = git status --porcelain
    if ($status) {
        Write-Host "⚠️  Uncommitted changes detected:" -ForegroundColor Yellow
        Write-Host $status
        Write-Host "   Consider committing changes before running pipeline" -ForegroundColor Yellow
    } else {
        Write-Host "✅ Working directory clean" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Not in a git repository or git not available" -ForegroundColor Red
}

# Test build locally (optional)
Write-Host "`n🔨 Testing local build..." -ForegroundColor Cyan
try {
    $buildResult = dotnet build $projectPath --configuration Release --verbosity minimal
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Local build successful" -ForegroundColor Green
    } else {
        Write-Host "❌ Local build failed" -ForegroundColor Red
    }
} catch {
    Write-Host "⚠️  .NET SDK not found or project issues" -ForegroundColor Yellow
    Write-Host "   Install .NET 8 SDK: https://dotnet.microsoft.com/download" -ForegroundColor Yellow
}

Write-Host "`n🚀 Next steps:" -ForegroundColor Cyan
Write-Host "1. Commit and push your changes to Azure Repos" -ForegroundColor White
Write-Host "2. Go to Azure DevOps → Pipelines → New pipeline" -ForegroundColor White
Write-Host "3. Choose 'Existing Azure Pipelines YAML file'" -ForegroundColor White
Write-Host "4. Select: azure-pipelines-simple.yml (recommended for first run)" -ForegroundColor White
Write-Host "5. Click 'Run' to execute the pipeline" -ForegroundColor White