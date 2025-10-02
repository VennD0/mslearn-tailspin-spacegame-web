# UseCase 3: Docker + Azure Kubernetes Service (AKS) 🐳☸️

This use case demonstrates containerizing the Tailspin SpaceGame .NET 8 web application and deploying it to Azure Kubernetes Service using Azure DevOps pipelines.

## 🎯 **What This Use Case Demonstrates**

- **Docker Containerization**: Multi-stage Docker build for .NET applications
- **Azure Container Registry (ACR)**: Secure container image storage
- **Azure Kubernetes Service (AKS)**: Container orchestration and scaling
- **CI/CD Pipeline**: Complete container build and deployment automation
- **Infrastructure as Code**: Bicep templates for AKS and ACR
- **Kubernetes Manifests**: Deployment, Service, and Ingress configurations

## 🏗️ **Architecture Overview**

```
┌─────────────────┐    ┌──────────────────┐    ┌───────────────────┐
│   Azure DevOps  │───▶│ Azure Container  │───▶│ Azure Kubernetes  │
│    Pipeline     │    │   Registry       │    │    Service        │
└─────────────────┘    └──────────────────┘    └───────────────────┘
         │                       │                        │
         ▼                       ▼                        ▼
┌─────────────────┐    ┌──────────────────┐    ┌───────────────────┐
│ Docker Build    │    │ Container Images │    │ Running Pods      │
│ .NET App        │    │ tailspin/web:tag │    │ Load Balancer     │
└─────────────────┘    └──────────────────┘    └───────────────────┘
```

## 📁 **Repository Structure**

```
usecase3-docker-aks/
├── Dockerfile                      # Multi-stage Docker build
├── .dockerignore                   # Docker build exclusions
├── azure-pipelines.yml             # Container CI/CD pipeline
├── setup-usecase3.ps1              # Infrastructure deployment script
├── k8s/                            # Kubernetes manifests
│   ├── namespace.yaml              # Kubernetes namespace
│   ├── deployment.yaml             # Application deployment
│   ├── service.yaml                # Load balancer service
│   └── ingress.yaml                # HTTP routing (optional)
├── infra/
│   └── aks-infrastructure.bicep    # AKS + ACR infrastructure
└── Tailspin.SpaceGame.Web/         # .NET 8 web application
```

## 🚀 **Quick Start**

### 1. Deploy Infrastructure

```powershell
# Run the setup script to deploy AKS and ACR
./setup-usecase3.ps1 -ResourceGroupName "rg-tailspin-aks" -Location "East US"
```

### 2. Configure Azure DevOps

1. **Create Service Connections**:
   - **Docker Registry**: Connect to your ACR
   - **Kubernetes**: Connect to your AKS cluster

2. **Update Pipeline Variables**:
   - Replace `#{ACR_NAME}#` with your actual ACR name
   - Update service connection names in `azure-pipelines.yml`

3. **Create Pipeline**:
   - Source: GitHub repository
   - Branch: `usecase3-docker-aks`
   - Pipeline file: `azure-pipelines.yml`

### 3. Run Pipeline

The pipeline will:
1. ✅ Build and test the .NET application
2. ✅ Create Docker container image
3. ✅ Push image to Azure Container Registry
4. ✅ Deploy to Azure Kubernetes Service
5. ✅ Expose application via Load Balancer

## 🐳 **Docker Configuration**

### Multi-Stage Dockerfile
- **Build Stage**: Compiles .NET application
- **Publish Stage**: Prepares application for deployment
- **Runtime Stage**: Minimal runtime image with security hardening

### Key Features:
- ✅ Non-root user for security
- ✅ Health checks
- ✅ Optimized layer caching
- ✅ Minimal attack surface

## ☸️ **Kubernetes Configuration**

### Resources Created:
- **Namespace**: `tailspin` (isolation)
- **Deployment**: 3 replicas with rolling updates
- **Service**: LoadBalancer for external access
- **Ingress**: HTTP routing (optional)

### Production Features:
- ✅ Resource limits and requests
- ✅ Liveness and readiness probes
- ✅ Security contexts
- ✅ Horizontal scaling capabilities

## 🔧 **Infrastructure Components**

| Component | Purpose | Configuration |
|-----------|---------|---------------|
| **Azure Container Registry** | Store container images | Basic SKU, admin enabled |
| **Azure Kubernetes Service** | Container orchestration | 3 nodes, auto-scaling |
| **Log Analytics Workspace** | Monitoring and logging | 30-day retention |
| **System-assigned Identity** | Secure ACR access | AcrPull role assignment |

## 📊 **Pipeline Stages**

### Stage 1: Build & Push
1. **Restore** .NET dependencies
2. **Build** application
3. **Test** with unit tests
4. **Docker Build** multi-stage image
5. **Push** to Azure Container Registry

### Stage 2: Deploy
1. **Create/Update** Kubernetes namespace
2. **Deploy** application manifests
3. **Verify** deployment status
4. **Display** connection information

## 🔍 **Monitoring & Troubleshooting**

### Check Deployment Status
```bash
# Get pods status
kubectl get pods -n tailspin

# Check service
kubectl get services -n tailspin

# View logs
kubectl logs -n tailspin -l app=spacegame-web

# Describe pod for troubleshooting
kubectl describe pod -n tailspin -l app=spacegame-web
```

### Access Application
```bash
# Get external IP (LoadBalancer)
kubectl get service tailspin-spacegame-web-service -n tailspin

# Port forward for testing
kubectl port-forward -n tailspin service/tailspin-spacegame-web-service 8080:80
```

## 🛡️ **Security Features**

- **Container Security**:
  - Non-root user execution
  - Read-only root filesystem option
  - Capability dropping
  - Security contexts

- **Kubernetes Security**:
  - Namespace isolation
  - RBAC enabled
  - Network policies ready
  - Resource quotas

- **Azure Security**:
  - Managed identities
  - Private networking options
  - Azure AD integration
  - Key Vault integration ready

## 📈 **Scaling & Performance**

### Horizontal Pod Autoscaler (HPA)
```yaml
# Add to k8s/ directory for auto-scaling
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: spacegame-web-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: tailspin-spacegame-web
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## 🔄 **CI/CD Best Practices**

- **Automated Testing**: Unit tests in pipeline
- **Image Scanning**: Security vulnerability checks
- **Rolling Deployments**: Zero-downtime updates
- **Health Checks**: Application availability verification
- **Monitoring Integration**: Azure Monitor + Log Analytics

## 🎯 **Use Cases for This Pattern**

- **Microservices Architecture**: Containerized service deployment
- **Cloud-Native Applications**: Kubernetes-first approach
- **Scalable Web Applications**: Auto-scaling capabilities
- **DevOps Maturity**: Advanced CI/CD practices
- **Multi-Environment Deployments**: Environment-specific configurations

## 🔗 **Related Learning Resources**

- [Azure Kubernetes Service Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Azure Container Registry Documentation](https://docs.microsoft.com/en-us/azure/container-registry/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

---

**🎉 This completes UseCase 3: Docker + AKS deployment pattern for the Tailspin SpaceGame application!**