# Kubernetes Load Test Dashboard Setup Script for Windows

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Kubernetes Load Test Dashboard Setup" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if minikube is running
Write-Host "Checking Minikube status..." -ForegroundColor Yellow
$minikubeStatus = minikube status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Minikube is not running. Starting Minikube..." -ForegroundColor Red
    minikube start
} else {
    Write-Host "✅ Minikube is running" -ForegroundColor Green
}

Write-Host ""
Write-Host "Setting Docker environment to use Minikube's Docker daemon..." -ForegroundColor Yellow
& minikube -p minikube docker-env --shell powershell | Invoke-Expression

Write-Host ""
Write-Host "Building Docker images..." -ForegroundColor Yellow
Write-Host "→ Building backend image..." -ForegroundColor Cyan
docker build -t loadtest-backend:latest ./backend

Write-Host "→ Building frontend image..." -ForegroundColor Cyan
docker build -t loadtest-frontend:latest ./frontend

Write-Host ""
Write-Host "Enabling metrics-server (required for HPA)..." -ForegroundColor Yellow
minikube addons enable metrics-server

Write-Host ""
Write-Host "Deploying to Kubernetes..." -ForegroundColor Yellow
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml

Write-Host ""
Write-Host "Waiting for deployments to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=120s deployment/backend
kubectl wait --for=condition=available --timeout=120s deployment/frontend

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "✅ Deployment Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Access your application:" -ForegroundColor Cyan
Write-Host "  Frontend: http://localhost:30080" -ForegroundColor White
Write-Host "  Backend API: http://localhost:30500" -ForegroundColor White
Write-Host ""
Write-Host "Open the Minikube Dashboard to watch the magic:" -ForegroundColor Cyan
Write-Host "  minikube dashboard" -ForegroundColor Yellow
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Cyan
Write-Host "  kubectl get pods -w              # Watch pods in real-time" -ForegroundColor White
Write-Host "  kubectl get hpa -w               # Watch autoscaler" -ForegroundColor White
Write-Host "  kubectl top pods                 # View resource usage" -ForegroundColor White
Write-Host "  kubectl describe hpa backend-hpa # HPA details" -ForegroundColor White
Write-Host ""
Write-Host "When you're done:" -ForegroundColor Cyan
Write-Host "  kubectl delete -f k8s/           # Remove all resources" -ForegroundColor White
Write-Host "==========================================" -ForegroundColor Cyan
