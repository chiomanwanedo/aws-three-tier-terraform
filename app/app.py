from flask import Flask, jsonify, request
import psycopg2
import redis
import os
import json

app = Flask(__name__)


# Redis connection
redis_client = redis.Redis(
    host=os.environ.get('REDIS_HOST'),
    port=6379,
    decode_responses=True
)

# Aurora connection
def get_db_connection():
    conn = psycopg2.connect(
        host=os.environ.get('DB_HOST'),
        database=os.environ.get('DB_NAME'),
        user=os.environ.get('DB_USER'),
        password=os.environ.get('DB_PASSWORD')
    )
    return conn


@app.route('/health')
def health():
    return jsonify({"status": "ok"}), 200   


@app.route('/products')
def get_products():
    cache_key = "products"
    
    # Check Redis first
    cached_data = redis_client.get(cache_key)
    if cached_data:
        return jsonify({"source": "cache", "data": json.loads(cached_data)}), 200
    
    # Cache miss — query Aurora
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT id, name, price, stock FROM products")
    rows = cur.fetchall()
    cur.close()
    conn.close()
    
    products = [{"id": r[0], "name": r[1], "price": r[2], "stock": r[3]} for r in rows]
    
    # Store in Redis for 60 seconds
    redis_client.setex(cache_key, 60, json.dumps(products))
    
    return jsonify({"source": "database", "data": products}), 200


@app.route('/products', methods=['POST'])
def add_product():
    data = request.get_json()
    
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO products (name, price, stock) VALUES (%s, %s, %s) RETURNING id",
        (data['name'], data['price'], data['stock'])
    )
    product_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()
    
    # Invalidate cache
    redis_client.delete("products")
    
    return jsonify({"message": "Product added", "id": product_id}), 201


@app.route('/products/<int:product_id>', methods=['PUT'])
def update_product(product_id):
    data = request.get_json()
    
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        "UPDATE products SET name=%s, price=%s, stock=%s WHERE id=%s",
        (data['name'], data['price'], data['stock'], product_id)
    )
    conn.commit()
    cur.close()
    conn.close()
    
    # Invalidate cache
    redis_client.delete("products")
    
    return jsonify({"message": "Product updated"}), 200


@app.route('/products/<int:product_id>', methods=['DELETE'])
def delete_product(product_id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("DELETE FROM products WHERE id=%s", (product_id,))
    conn.commit()
    cur.close()
    conn.close()
    
    # Invalidate cache
    redis_client.delete("products")
    
    return jsonify({"message": "Product deleted"}), 200


def init_db():
    conn = get_db_connection()
    cur = conn.cursor()
    
    cur.execute("""
        CREATE TABLE IF NOT EXISTS products (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            price DECIMAL(10,2),
            stock INTEGER
        )
    """)
    
    cur.execute("SELECT COUNT(*) FROM products")
    count = cur.fetchone()[0]
    
    if count == 0:
        products = [
            ("Nike Air Max", 89.99, 150),
            ("Adidas Samba", 74.99, 75),
            ("New Balance 574", 69.99, 200),
            ("Puma RS-X", 64.99, 100),
            ("Vans Old Skool", 59.99, 180)
        ]
        cur.executemany(
            "INSERT INTO products (name, price, stock) VALUES (%s, %s, %s)",
            products
        )
    
    conn.commit()
    cur.close()
    conn.close()


if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=80)