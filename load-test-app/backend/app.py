from flask import Flask, jsonify, request
from flask_cors import CORS
import time
import hashlib
import os

app = Flask(__name__)
CORS(app)

def cpu_intensive_task(iterations=1000000):
    """Simulate CPU-intensive work by computing hashes"""
    result = "start"
    for i in range(iterations):
        result = hashlib.sha256(result.encode()).hexdigest()
    return result

@app.route('/health')
def health():
    return jsonify({"status": "healthy", "pod": os.environ.get('HOSTNAME', 'unknown')})

@app.route('/api/work', methods=['POST'])
def do_work():
    data = request.get_json() or {}
    intensity = data.get('intensity', 'light')
    
    # Map intensity to iterations
    intensity_map = {
        'light': 500000,
        'medium': 2000000,
        'heavy': 5000000
    }
    
    iterations = intensity_map.get(intensity, 500000)
    
    start_time = time.time()
    result = cpu_intensive_task(iterations)
    duration = time.time() - start_time
    
    return jsonify({
        "status": "completed",
        "intensity": intensity,
        "duration": round(duration, 2),
        "pod": os.environ.get('HOSTNAME', 'unknown'),
        "hash_preview": result[:16]
    })

@app.route('/')
def root():
    return jsonify({
        "service": "Load Test Backend",
        "pod": os.environ.get('HOSTNAME', 'unknown'),
        "endpoints": ["/health", "/api/work"]
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
