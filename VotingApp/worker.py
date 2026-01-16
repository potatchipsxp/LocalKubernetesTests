import os
import redis
import psycopg2
import json
import time

def get_redis_conn():
    r = redis.Redis(
        host=os.environ.get('REDIS_HOST', 'redis'),
        port=6379,
        socket_timeout=5
    )
    return r

def get_postgres_conn():
    conn = psycopg2.connect(
        host=os.environ.get('POSTGRES_HOST', 'db'),
        database='postgres',
        user='postgres',
        password='postgres'
    )
    return conn

def init_db(conn):
    cur = conn.cursor()
    cur.execute('''
        CREATE TABLE IF NOT EXISTS votes (
            id VARCHAR(255) NOT NULL UNIQUE,
            vote VARCHAR(255) NOT NULL
        )
    ''')
    conn.commit()
    cur.close()

def process_vote(redis_conn, postgres_conn):
    # Get vote from Redis queue
    raw_vote = redis_conn.blpop('votes', timeout=5)
    
    if raw_vote:
        vote_data = json.loads(raw_vote[1])
        voter_id = vote_data['voter_id']
        vote = vote_data['vote']
        
        # Add some CPU load to trigger scaling
        _ = sum(i*i for i in range(50000))
        
        # Store in PostgreSQL
        cur = postgres_conn.cursor()
        try:
            cur.execute(
                'INSERT INTO votes (id, vote) VALUES (%s, %s) ON CONFLICT (id) DO UPDATE SET vote = %s',
                (voter_id, vote, vote)
            )
            postgres_conn.commit()
            print(f"Processed vote: {voter_id} -> {vote}")
        except Exception as e:
            print(f"Error processing vote: {e}")
            postgres_conn.rollback()
        finally:
            cur.close()

if __name__ == '__main__':
    print("Worker starting...")
    
    # Wait for services to be ready
    time.sleep(5)
    
    redis_conn = get_redis_conn()
    postgres_conn = get_postgres_conn()
    
    init_db(postgres_conn)
    
    print("Worker ready, processing votes...")
    
    while True:
        try:
            process_vote(redis_conn, postgres_conn)
        except Exception as e:
            print(f"Error in worker loop: {e}")
            time.sleep(1)
