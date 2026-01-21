# Kubernetes Load Test Dashboard

A hands-on application designed to showcase Kubernetes features like auto-scaling, self-healing, and resource management. Watch your pods scale up and down in real-time as you generate load!

## 🎯 What You'll Learn

- **Horizontal Pod Autoscaling (HPA)**: Pods automatically scale based on CPU usage
- **Resource Management**: See how CPU and memory limits work
- **Self-Healing**: Watch pods restart when they fail
- **Service Discovery**: See how services route traffic to multiple pods
- **Real-time Monitoring**: View metrics in the Minikube dashboard

## 📁 Project Structure

```
load-test-app/
├── backend/
│   ├── app.py              # Flask API with CPU-intensive endpoints
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/
│   ├── index.html          # Interactive dashboard
│   └── Dockerfile
├── k8s/
│   ├── backend-deployment.yaml    # Backend + HPA config
│   └── frontend-deployment.yaml   # Frontend config
├── deploy.ps1              # Windows deployment script
├── deploy.sh               # Linux/Mac deployment script
└── README.md
```

## 🚀 Quick Start

### Prerequisites
- Minikube installed and running
- kubectl installed
- Docker Desktop running (for Windows)

### Deployment

**For Windows (PowerShell):**
```powershell
cd load-test-app
.\deploy.ps1
```

**For Linux/Mac:**
```bash
cd load-test-app
chmod +x deploy.sh
./deploy.sh
```

### Manual Deployment (if scripts don't work)

1. **Start Minikube** (if not running):
```bash
minikube start
```

2. **Set Docker environment to use Minikube**:

Windows (PowerShell):
```powershell
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
```

Linux/Mac:
```bash
eval $(minikube docker-env)
```

3. **Build the Docker images**:
```bash
docker build -t loadtest-backend:latest ./backend
docker build -t loadtest-frontend:latest ./frontend
```

4. **Enable metrics-server** (required for autoscaling):
```bash
minikube addons enable metrics-server
```

5. **Deploy to Kubernetes**:
```bash
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml
```

6. **Wait for pods to be ready**:
```bash
kubectl get pods -w
```

## 🎮 How to Use

### 1. Open the Dashboard
```bash
minikube dashboard
```

This opens the Kubernetes dashboard in your browser. Navigate to:
- **Workloads → Deployments** - See your deployments
- **Workloads → Pods** - Watch pods scale up/down
- **Horizontal Pod Autoscalers** - Monitor the autoscaler

### 2. Open the Load Test App

Open your browser to: **http://localhost:30080**

You'll see a colorful dashboard with buttons to generate load.

### 3. Generate Load and Watch!

**Option 1: Manual Load**
- Click "Light Load" - Minimal CPU usage
- Click "Medium Load" - Moderate CPU usage  
- Click "Heavy Load" - High CPU usage (triggers scaling faster)

**Option 2: Automatic Load**
- Click "Start Auto Load" - Sends requests every 2 seconds
- This will steadily increase CPU usage
- Watch the Minikube dashboard as new pods spin up!

### 4. What to Watch For

In the **Minikube Dashboard**:

1. **Pods View**:
   - Initial: 1 backend pod running
   - After load: Multiple pods (up to 10) spin up
   - Watch the CPU graphs climb
   - See new pods in "ContainerCreating" → "Running" state

2. **Deployments View**:
   - Replicas count increases (1 → 2 → 3 → ...)
   - Desired vs Current vs Available counts

3. **HPA (Horizontal Pod Autoscaler)**:
   ```bash
   kubectl get hpa -w
   ```
   Output shows:
   - Current CPU percentage
   - Target CPU (50%)
   - Current/Desired replicas

### 5. Useful Commands

**Watch pods scale in real-time:**
```bash
kubectl get pods -w
```

**Watch the autoscaler:**
```bash
kubectl get hpa -w
```

**Check resource usage:**
```bash
kubectl top pods
```

**Get detailed HPA info:**
```bash
kubectl describe hpa backend-hpa
```

**View pod logs:**
```bash
kubectl logs -f <pod-name>
```

**See all resources:**
```bash
kubectl get all
```

## 🔬 Experiments to Try

### Experiment 1: Trigger Fast Scaling
1. Open the dashboard
2. Click "Heavy Load" 5-10 times rapidly
3. Watch pods spin up within 15-30 seconds
4. Check `kubectl get hpa -w` to see CPU% spike

### Experiment 2: Scale Down
1. After generating heavy load
2. Stop all requests (click "Stop Auto Load")
3. Wait ~2-3 minutes
4. Watch pods scale back down to 1

### Experiment 3: Self-Healing
1. Generate some load to have multiple pods
2. Delete a pod manually:
   ```bash
   kubectl delete pod <pod-name>
   ```
3. Watch Kubernetes immediately create a replacement
4. Check the dashboard - requests still work!

### Experiment 4: Resource Limits
1. Generate heavy load
2. Run `kubectl describe pod <pod-name>`
3. Look at the "Limits" and "Requests" section
4. Notice pods can't use more than 500m CPU

### Experiment 5: Rolling Updates
1. Modify the backend code (change the response message)
2. Rebuild: `docker build -t loadtest-backend:latest ./backend`
3. Update: `kubectl rollout restart deployment/backend`
4. Watch the dashboard - zero downtime as pods update one by one!

## 📊 Understanding the HPA Configuration

In `backend-deployment.yaml`:

```yaml
minReplicas: 1          # Minimum pods
maxReplicas: 10         # Maximum pods
averageUtilization: 50  # Scale up when avg CPU > 50%
```

**Resource Limits:**
```yaml
requests:
  cpu: 100m      # Reserve 0.1 CPU
  memory: 128Mi
limits:
  cpu: 500m      # Max 0.5 CPU per pod
  memory: 256Mi
```

The HPA watches CPU usage. When average utilization across all pods exceeds 50%, it adds more pods. When usage drops, it scales down after a stabilization period.

## 🧹 Cleanup

**Remove all resources:**
```bash
kubectl delete -f k8s/
```

**Or delete everything in the namespace:**
```bash
kubectl delete deployment,service,hpa --all
```

**Stop Minikube:**
```bash
minikube stop
```

## 🐛 Troubleshooting

### Pods not scaling?

1. **Check if metrics-server is running:**
```bash
kubectl get pods -n kube-system | grep metrics-server
```

If not running:
```bash
minikube addons enable metrics-server
```

2. **Check HPA status:**
```bash
kubectl describe hpa backend-hpa
```

Look for errors or "unknown" CPU metrics. Metrics may take 1-2 minutes to start appearing.

### Can't access the app?

1. **Check services:**
```bash
kubectl get svc
```

Ensure `backend-service` shows port `30500` and `frontend-service` shows `30080`.

2. **Check pods are running:**
```bash
kubectl get pods
```

All pods should be in "Running" status.

3. **Get Minikube IP:**
```bash
minikube ip
```

Try accessing: `http://<minikube-ip>:30080`

### Docker images not found?

Make sure you're using Minikube's Docker daemon:

Windows:
```powershell
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
```

Linux/Mac:
```bash
eval $(minikube docker-env)
```

Then rebuild the images.

### HPA shows "unknown" for CPU?

Wait 1-2 minutes after deployment. The metrics-server needs time to collect data. You can check metrics with:
```bash
kubectl top pods
```

## 📚 Next Steps

Once you're comfortable with this app, try:

1. **Modify scaling thresholds** - Change the HPA target from 50% to 30%
2. **Add memory-based scaling** - Scale based on memory instead of CPU
3. **Experiment with different resource limits** - See how it affects scaling
4. **Add a database** - Deploy Redis or PostgreSQL and connect it
5. **Try rolling updates** - Modify the app and deploy new versions
6. **Set up health checks** - The app already has them - try breaking them!

## 🎓 Key Kubernetes Concepts Demonstrated

- **Deployments** - Declarative way to manage pods
- **Services** - Stable network endpoints for pods
- **NodePort** - Exposing services outside the cluster
- **Horizontal Pod Autoscaler** - Automatic scaling based on metrics
- **Resource Requests/Limits** - CPU and memory management
- **Liveness/Readiness Probes** - Health checking
- **Labels and Selectors** - Organizing and selecting resources

Enjoy learning Kubernetes! 🚀
