#!/bin/bash

echo "=========================================="
echo "Kubernetes Load Test Dashboard Setup"
echo "=========================================="
echo ""

# Check if minikube is running
echo "Checking Minikube status..."
minikube status > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Minikube is not running. Starting Minikube..."
    minikube start
else
    echo "✅ Minikube is running"
fi

echo ""
echo "Setting Docker environment to use Minikube's Docker daemon..."
eval $(minikube docker-env)

echo ""
echo "Building Docker images..."
echo "→ Building backend image..."
docker build -t loadtest-backend:latest ./backend

echo "→ Building frontend image..."
docker build -t loadtest-frontend:latest ./frontend

echo ""
echo "Enabling metrics-server (required for HPA)..."
minikube addons enable metrics-server

echo ""
echo "Deploying to Kubernetes..."
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml

echo ""
echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/backend
kubectl wait --for=condition=available --timeout=120s deployment/frontend

echo ""
echo "=========================================="
echo "✅ Deployment Complete!"
echo "=========================================="
echo ""
echo "Access your application:"
echo "  Frontend: http://localhost:30080"
echo "  Backend API: http://localhost:30500"
echo ""
echo "Open the Minikube Dashboard to watch the magic:"
echo "  minikube dashboard"
echo ""
echo "Useful commands:"
echo "  kubectl get pods -w              # Watch pods in real-time"
echo "  kubectl get hpa -w               # Watch autoscaler"
echo "  kubectl top pods                 # View resource usage"
echo "  kubectl describe hpa backend-hpa # HPA details"
echo ""
echo "When you're done:"
echo "  kubectl delete -f k8s/           # Remove all resources"
echo "=========================================="
