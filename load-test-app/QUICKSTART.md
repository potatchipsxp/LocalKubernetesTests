# Quick Start Cheat Sheet

## Deployment (Choose One)

### Windows (PowerShell):
```powershell
cd load-test-app
.\deploy.ps1
```

### Linux/Mac:
```bash
cd load-test-app
chmod +x deploy.sh
./deploy.sh
```

## Access the App

- **Dashboard**: http://localhost:30080
- **Backend API**: http://localhost:30500
- **Minikube Dashboard**: `minikube dashboard`

## Essential Commands

```bash
# Watch pods scale in real-time
kubectl get pods -w

# Watch autoscaler
kubectl get hpa -w

# Check resource usage
kubectl top pods

# View all resources
kubectl get all

# See HPA details
kubectl describe hpa backend-hpa

# View pod logs
kubectl logs -f deployment/backend
```

## Quick Test

1. Open http://localhost:30080
2. Click "Start Auto Load"
3. Open `minikube dashboard` in another window
4. Navigate to Workloads → Pods
5. Watch pods scale from 1 → multiple!

## Cleanup

```bash
kubectl delete -f k8s/
```

## Troubleshooting

**Pods not scaling?**
```bash
minikube addons enable metrics-server
kubectl get hpa -w  # Wait for CPU metrics to appear
```

**Can't access app?**
```bash
kubectl get svc  # Check services are running
kubectl get pods # Check pods are running
```

**Docker images not found?**

Windows:
```powershell
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
```

Linux/Mac:
```bash
eval $(minikube docker-env)
```

Then rebuild: `docker build -t loadtest-backend:latest ./backend`
