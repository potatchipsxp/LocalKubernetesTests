#!/bin/bash

echo "🧹 Cleaning up Voting App..."

kubectl delete -f k8s-vote.yaml
kubectl delete -f k8s-worker.yaml
kubectl delete -f k8s-result.yaml
kubectl delete -f k8s-db.yaml
kubectl delete -f k8s-redis.yaml

echo "✅ Cleanup complete!"
