# Branch Strategy for Tailspin Space Game DevOps Use Cases

This repository supports two different Azure DevOps pipeline use cases, organized by branch:

## 🌿 Branch Structure

### `main` Branch - UseCase1: Classic ARM DevOps
**Purpose**: Simple, straightforward Azure DevOps pipeline  
**Pattern**: Build → Deploy (single job)  
**Target**: Classic ARM deployment pattern  
**Pipeline File**: `azure-pipelines.yml`

**Features**:
- ✅ Single job build and deploy
- ✅ Conditional deployment (main branch only)
- ✅ Simple artifact publishing
- ✅ Direct Azure Web App deployment

**Azure DevOps Setup**: Point your UseCase1 pipeline to the `main` branch

---

### `multistage-pipeline` Branch - UseCase2: Multi-Stage with Deployment Slots
**Purpose**: Advanced multi-stage pipeline with blue-green deployments  
**Pattern**: Build → Dev → Test → Staging (4 stages)  
**Target**: Enterprise deployment with deployment slots  
**Pipeline File**: `azure-pipelines.yml`

**Features**:
- ✅ Multi-stage pipeline (Build → Dev → Test → Staging)
- ✅ Environment targeting with approvals
- ✅ Deployment slots for zero-downtime deployments
- ✅ Blue-green deployment pattern
- ✅ Artifact promotion between stages

**Azure DevOps Setup**: Point your UseCase2 pipeline to the `multistage-pipeline` branch

---

## 🚀 How to Use

### For UseCase1 (Classic ARM):
1. In Azure DevOps, create/edit your pipeline
2. Set **Source Branch**: `main`
3. Pipeline will use the simple build+deploy pattern

### For UseCase2 (Multi-Stage):
1. In Azure DevOps, create/edit your pipeline  
2. Set **Source Branch**: `multistage-pipeline`
3. Pipeline will use the 4-stage deployment pattern

### Current Infrastructure Status:
- ✅ **UAT Environment**: `https://tailspin-uat-webapp.azurewebsites.net`
- ✅ **Production**: `https://tailspin-prod-webapp.azurewebsites.net`
- ✅ **Staging Slot**: `https://tailspin-prod-webapp-staging.azurewebsites.net`

## 🔧 Infrastructure

Both use cases share the same Azure infrastructure:
- Resource Group: `rg-tailspin-demo`
- UAT App Service: `tailspin-uat-webapp` (Free F1)
- Production App Service: `tailspin-prod-webapp` (Standard S1) with staging slot
- Bicep Templates: Available in `infra/` folder

## 📝 Notes

- Both pipelines target the same Azure resources
- UseCase1 is simpler and suitable for basic deployments
- UseCase2 demonstrates enterprise-grade deployment patterns
- Infrastructure provisioned via Bicep (Infrastructure as Code)
- Blue-green deployments achieved through slot swapping