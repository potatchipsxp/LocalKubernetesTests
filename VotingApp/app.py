from flask import Flask, render_template, request, make_response
import os
import socket
import random
import json
import redis
import time

app = Flask(__name__)

# Get Redis connection
def get_redis():
    redis_host = os.environ.get('REDIS_HOST', 'redis')
    return redis.Redis(host=redis_host, port=6379, socket_timeout=5)

@app.route("/", methods=['POST','GET'])
def hello():
    voter_id = request.cookies.get('voter_id')
    if not voter_id:
        voter_id = hex(random.getrandbits(64))[2:-1]

    vote = None

    if request.method == 'POST':
        r = get_redis()
        vote = request.form['vote']
        data = json.dumps({'voter_id': voter_id, 'vote': vote})
        r.rpush('votes', data)
        
        # Add some CPU load to trigger scaling
        _ = sum(i*i for i in range(10000))

    resp = make_response(render_template(
        'index.html',
        option_a=os.getenv('OPTION_A', "Cats"),
        option_b=os.getenv('OPTION_B', "Dogs"),
        hostname=socket.gethostname(),
        vote=vote,
    ))
    resp.set_cookie('voter_id', voter_id)
    return resp

@app.route("/health")
def health():
    return "healthy"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80, debug=True)
