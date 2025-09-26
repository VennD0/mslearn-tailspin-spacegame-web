# Azure DevOps CI/CD Pipeline Setup Guide

This guide will help you set up a complete CI/CD pipeline for the Tailspin Space Game web application.

## Prerequisites

1. **Azure DevOps Organization** - You'll need access to Azure DevOps
2. **Azure Subscription** - For deploying resources
3. **Service Connection** - Connection between Azure DevOps and Azure

## Setup Instructions

### 1. Create Service Connection

1. Go to **Project Settings** > **Service connections**
2. Click **New service connection**
3. Select **Azure Resource Manager**
4. Choose **Service principal (automatic)**
5. Select your **Subscription** and **Resource group** (or leave blank for subscription-level access)
6. Name it (e.g., `azure-connection`)

### 2. Create Variable Groups

#### Development Variables (`dev-variables`)
1. Go to **Pipelines** > **Library** > **Variable groups**
2. Click **+ Variable group**
3. Name: `dev-variables`
4. Add variables:
   - `serviceConnectionName`: Your service connection name
   - `subscriptionId`: Your Azure subscription ID
   - `resourceGroupName`: `tailspin-spacegame-dev-rg`
   - `location`: `East US` (or your preferred location)
   - `appName`: `tailspin-spacegame`
   - `environment`: `dev`
   - `skuName`: `B1`

#### Production Variables (`prod-variables`)
1. Create another variable group: `prod-variables`
2. Add similar variables but for production:
   - `serviceConnectionName`: Your service connection name
   - `subscriptionId`: Your Azure subscription ID
   - `resourceGroupName`: `tailspin-spacegame-prod-rg`
   - `location`: `East US`
   - `appName`: `tailspin-spacegame`
   - `environment`: `prod`
   - `skuName`: `S1`

### 3. Create Build Pipeline

1. Go to **Pipelines** > **Pipelines**
2. Click **New pipeline**
3. Select **Azure Repos Git** (or your source)
4. Select your repository
5. Select **Existing Azure Pipelines YAML file**
6. Choose `/azure-pipelines.yml`
7. Click **Run**

### 4. Create Release Pipeline

1. Go to **Pipelines** > **Pipelines**
2. Click **New pipeline**
3. Select **Azure Repos Git**
4. Select your repository
5. Select **Existing Azure Pipelines YAML file**
6. Choose `/azure-pipelines-release.yml`
7. **Important**: Update the `source` name in the pipeline to match your build pipeline name

### 5. Create Environments (Optional but Recommended)

1. Go to **Pipelines** > **Environments**
2. Create two environments:
   - `dev` - for development deployments
   - `prod` - for production deployments (add approval gates)

### 6. Configure Approvals for Production

1. In the `prod` environment, click **...** > **Approvals and checks**
2. Add **Approvals** and specify reviewers
3. This ensures production deployments require manual approval

## Pipeline Structure

### Build Pipeline (`azure-pipelines.yml`)
- **Triggers**: On all branches
- **Stages**: 
  - Build (compiles, tests, packages the application)
- **Artifacts**: Creates a 'drop' artifact containing:
  - Compiled application (Debug & Release)
  - ARM templates for infrastructure
  - Build info

### Release Pipeline (`azure-pipelines-release.yml`)
- **Triggers**: After successful build
- **Stages**:
  - Deploy_Dev: Deploys to development environment
  - Deploy_Prod: Deploys to production (only from main branch, after dev success)

## Infrastructure

The ARM template (`infra/main.json`) creates:
- **App Service Plan** (Linux)
- **App Service** (Web App with .NET 8.0)
- **Application Insights** (for monitoring)

## Customization

### To modify the infrastructure:
1. Edit `infra/main.json` (ARM template)
2. Edit `infra/main.parameters.json` (default parameters)
3. Update variable groups with new parameters if needed

### To add more environments:
1. Create new variable group (e.g., `test-variables`)
2. Add new stage to `azure-pipelines-release.yml`
3. Create new environment in Azure DevOps

## Monitoring

After deployment, you can monitor your application:
- **App Service**: Azure Portal > App Services > Your app
- **Application Insights**: Azure Portal > Application Insights > Your app insights instance
- **Logs**: Available in both App Service and Application Insights

## Troubleshooting

### Common Issues:
1. **Service connection not found**: Ensure the service connection name in variable groups matches exactly
2. **Resource group doesn't exist**: The pipeline will create it automatically
3. **Permission issues**: Ensure your service connection has Contributor role on the subscription/resource group
4. **Build failures**: Check the build logs, ensure all dependencies are restored properly

### Useful Commands:
```bash
# To test locally
dotnet restore
dotnet build
dotnet run

# To check published files
dotnet publish -c Release -o ./publish
```

## Next Steps

1. Set up automated testing in the build pipeline
2. Add database deployments if needed
3. Configure monitoring and alerts
4. Set up branch policies for main branch
5. Add security scanning tasks
