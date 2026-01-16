# Kubernetes Voting App

A microservices voting application designed to demonstrate Kubernetes features like auto-scaling, load balancing, and resource management.

## Architecture

```
┌─────────┐      ┌─────────┐      ┌──────────┐      ┌────────────┐
│  Vote   │─────▶│  Redis  │─────▶│  Worker  │─────▶│ PostgreSQL │
│ (Flask) │      │ (Queue) │      │ (Python) │      │    (DB)    │
└─────────┘      └─────────┘      └──────────┘      └────────────┘
                                                            │
                                                            ▼
                                                     ┌──────────┐
                                                     │  Result  │
                                                     │ (Node.js)│
                                                     └──────────┘
```

## Components

- **Vote**: Frontend where users cast votes (Flask/Python)
- **Redis**: In-memory queue for votes
- **Worker**: Processes votes from Redis to PostgreSQL (Python)
- **PostgreSQL**: Persistent storage for votes
- **Result**: Real-time results dashboard (Node.js)

## Resource Constraints

Each component has CPU and memory limits to demonstrate scaling:

- **Vote pods**: 100m CPU request, 200m limit, scales 2-8 replicas
- **Worker pods**: 100m CPU request, 200m limit, scales 1-5 replicas
- **Auto-scaling triggers**: Scales at 50% CPU utilization

## Quick Start

### 1. Deploy the Application

```bash
cd voting-app
./deploy.sh
```

This will:
- Build all Docker images in Minikube
- Enable the metrics-server addon
- Deploy all services to Kubernetes
- Set up Horizontal Pod Autoscalers (HPA)
- Display the URLs for the vote and result apps

### 2. Open the Applications

The deploy script will show you the URLs, or get them with:

```bash
# Vote app
minikube service vote --url

# Results app
minikube service result --url
```

### 3. Watch Kubernetes in Action

**Open the Minikube Dashboard:**
```bash
minikube dashboard
```

**Watch pods scale in real-time:**
```bash
# Watch HPA status
kubectl get hpa -w

# Watch pods
kubectl get pods -w

# Watch detailed pod metrics
kubectl top pods
```

### 4. Generate Load

1. Open the Vote app URL in your browser
2. **Click votes rapidly** (Cats or Dogs)
3. Open multiple browser tabs and vote simultaneously
4. Watch the dashboard as:
   - CPU usage increases
   - New pods are created automatically
   - Load is distributed across pods
   - Pods scale back down when load decreases

### 5. View Live Results

Open the Results app URL to see:
- Real-time vote counts
- Bar chart updating every 2 seconds
- Total votes cast

## What You'll See in the Dashboard

### Deployments
- **vote**: 2-8 replicas (auto-scales)
- **worker**: 1-5 replicas (auto-scales)
- **result**: 1 replica (fixed)
- **redis**: 1 replica (fixed)
- **db**: 1 replica (fixed)

### Pods
- Each pod shows its CPU and memory usage
- Watch new pods appear when you generate load
- Pod names include the hostname shown in the vote app

### HPA (Horizontal Pod Autoscaler)
- Shows current CPU usage vs target (50%)
- Shows current vs desired replica count
- Watch it make scaling decisions in real-time

### Services
- **vote**: NodePort 31000 (external access)
- **result**: NodePort 31001 (external access)
- **redis**, **db**: ClusterIP (internal only)

## Monitoring Commands

```bash
# Watch HPA activity
kubectl get hpa -w

# Check pod CPU/memory usage
kubectl top pods

# View pod logs
kubectl logs -f deployment/vote
kubectl logs -f deployment/worker
kubectl logs -f deployment/result

# Describe HPA to see scaling events
kubectl describe hpa vote-hpa
kubectl describe hpa worker-hpa

# View all resources
kubectl get all
```

## Cleanup

To remove all resources:

```bash
./cleanup.sh
```

## Troubleshooting

**Pods not scaling?**
- Ensure metrics-server is running: `kubectl get pods -n kube-system | grep metrics`
- Check HPA status: `kubectl describe hpa vote-hpa`
- Wait a minute after deploying - metrics collection takes time

**Can't access the apps?**
- Check minikube is running: `minikube status`
- Get service URLs: `minikube service vote --url`
- Check pod status: `kubectl get pods`

**Images not found?**
- Ensure you're using minikube's docker: `eval $(minikube docker-env)`
- Rebuild images: `docker build -t voting-app-vote:latest ./vote`

## Learning Points

This app demonstrates:

1. **Microservices Architecture**: Multiple services working together
2. **Horizontal Auto-Scaling**: Pods scale based on CPU usage
3. **Load Balancing**: Traffic distributed across multiple pods
4. **Resource Management**: CPU/memory requests and limits
5. **Service Discovery**: Services find each other by name
6. **Health Checks**: Liveness probes ensure pods are healthy
7. **Rolling Updates**: Update deployments without downtime
8. **StatefulSets vs Deployments**: Database uses persistent storage

## Next Steps

Try these experiments:

1. **Update the app**: Change OPTION_A/OPTION_B in k8s-vote.yaml and redeploy
2. **Manual scaling**: `kubectl scale deployment vote --replicas=5`
3. **Stress test**: Use a load testing tool like `ab` or `hey`
4. **Check logs**: See which pod processed your vote
5. **Pod failures**: Delete a pod and watch it recreate automatically
6. **Resource limits**: Try increasing/decreasing CPU limits

Enjoy exploring Kubernetes! 🚀
