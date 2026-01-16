#!/bin/bash

set -e

echo "🚀 Building and deploying Voting App to Minikube..."

# Check if minikube is running
if ! minikube status > /dev/null 2>&1; then
    echo "❌ Minikube is not running. Please start it with 'minikube start'"
    exit 1
fi

# Set docker env to use minikube's docker daemon
echo "📦 Setting Docker environment to Minikube..."
eval $(minikube docker-env)

# Build Docker images
echo "🔨 Building Docker images..."
echo "  Building vote app..."
docker build -t voting-app-vote:latest ./vote

echo "  Building result app..."
docker build -t voting-app-result:latest ./result

echo "  Building worker app..."
docker build -t voting-app-worker:latest ./worker

# Enable metrics server for HPA
echo "📊 Enabling metrics-server..."
minikube addons enable metrics-server

# Wait for metrics server to be ready
echo "⏳ Waiting for metrics-server to be ready..."
kubectl wait --for=condition=ready pod -l k8s-app=metrics-server -n kube-system --timeout=60s || true
sleep 10

# Deploy to Kubernetes
echo "☸️  Deploying to Kubernetes..."
kubectl apply -f k8s-redis.yaml
kubectl apply -f k8s-db.yaml
kubectl apply -f k8s-vote.yaml
kubectl apply -f k8s-worker.yaml
kubectl apply -f k8s-result.yaml

# Wait for deployments
echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/redis
kubectl wait --for=condition=available --timeout=120s deployment/db
kubectl wait --for=condition=available --timeout=120s deployment/vote
kubectl wait --for=condition=available --timeout=120s deployment/worker
kubectl wait --for=condition=available --timeout=120s deployment/result

# Get URLs
VOTE_URL=$(minikube service vote --url)
RESULT_URL=$(minikube service result --url)

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🗳️  Vote App: $VOTE_URL"
echo "📊 Results App: $RESULT_URL"
echo ""
echo "📈 To see the dashboard:"
echo "   minikube dashboard"
echo ""
echo "🔍 To watch pods scale:"
echo "   kubectl get hpa -w"
echo "   kubectl get pods -w"
echo ""
echo "💡 Tips:"
echo "   - Click votes rapidly to generate load"
echo "   - Watch the dashboard to see pods scale up"
echo "   - CPU usage will trigger scaling at 50% of 100m (50m CPU)"
echo "   - Vote pods will scale from 2 to 8"
echo "   - Worker pods will scale from 1 to 5"
echo ""
