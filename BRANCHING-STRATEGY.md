# Advanced Branching Strategy for Multi-Stage Pipeline

## 🌿 **Recommended Branch Structure**

### **Branch Strategy:**
```
main (production-ready code)
├── develop (integration branch)
├── feature/new-homepage (feature development)
├── feature/user-authentication (feature development)
└── hotfix/critical-bug-fix (emergency fixes)
```

### **Pipeline Triggers by Branch:**

```yaml
# Enhanced trigger configuration
trigger:
  branches:
    include:
    - main          # Full pipeline: Build → UAT → Staging → Production
    - develop       # Partial pipeline: Build → UAT only
    - feature/*     # Build only (no deployment)
  paths:
    exclude:
    - README.md
    - docs/*
    - "*.md"

# Different behavior per branch
variables:
- ${{ if eq(variables['Build.SourceBranch'], 'refs/heads/main') }}:
  - name: deployToProduction
    value: true
- ${{ else }}:
  - name: deployToProduction
    value: false
```

## 🎯 **Pipeline Behavior by Branch:**

### **`main` Branch (Production)**
```
Push to main → Build → UAT → Production Staging → Slot Swap
```
- Full deployment pipeline
- Requires manual approval for production
- Zero-downtime deployment via slot swap

### **`develop` Branch (Integration)**
```
Push to develop → Build → UAT (stops here)
```
- Integration testing
- No production deployment
- Safe for testing new features together

### **`feature/*` Branches (Development)**
```
Push to feature/xyz → Build only
```
- Build validation only
- No deployment
- Quick feedback for developers

## 🚀 **How to Use This Strategy:**

### **1. Create develop branch:**
```bash
git checkout -b develop
git push -u origin develop
```

### **2. Create feature branch:**
```bash
git checkout develop
git checkout -b feature/improve-homepage
# Make your changes
git add .
git commit -m "Improve homepage design"
git push -u origin feature/improve-homepage
```

### **3. Merge flow:**
```bash
# 1. Feature → develop (via PR)
git checkout develop
git merge feature/improve-homepage

# 2. develop → main (via PR, triggers full pipeline)
git checkout main
git merge develop
```

## 📋 **For Your Current Demo:**

### **Recommendation: Stick with `main` branch**
Since you're demonstrating the pipeline functionality:

1. ✅ **Keep using `main` branch**
2. ✅ **Your current trigger is perfect:**
   ```yaml
   trigger:
   - main
   ```
3. ✅ **Every push to main will show the full pipeline flow**

### **Demo Scenario:**
1. Make a small change (like updating homepage text)
2. Commit to main: `git commit -m "Update homepage content"`
3. Push: `git push origin main`
4. Watch the full pipeline execute: Build → UAT → Staging → Production

## 🔄 **Pipeline Stages Explanation:**

### **Your Current Flow:**
```
main branch push
    ↓
Build Stage (always runs)
    ↓
UAT Deployment (automatic)
    ↓
Production Staging Slot (automatic)
    ↓
Slot Swap to Production (manual approval required)
```

This is perfect for demonstrating:
- ✅ Multi-stage deployment
- ✅ Deployment slots
- ✅ Manual approval gates
- ✅ Zero-downtime deployment

## 🎯 **Action Plan:**

**For immediate demo:** Use `main` branch (current setup is perfect)

**For future enhancement:** Consider the advanced branching strategy above