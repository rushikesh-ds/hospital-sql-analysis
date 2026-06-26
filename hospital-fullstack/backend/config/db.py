"""
MySQL connection configuration.
Edit the credentials below to match your local MySQL setup.
"""
import mysql.connector
from mysql.connector import pooling

DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "2708",          # <-- change this to your MySQL password
    "database": "hospital_db",
    "port": 3306,
}

# Connection pool for better performance under multiple requests
_pool = pooling.MySQLConnectionPool(
    pool_name="hospital_pool",
    pool_size=5,
    **DB_CONFIG
)


def get_connection():
    """Returns a pooled MySQL connection. Caller is responsible for closing it."""
    return _pool.get_connection()


def run_query(query, params=None, fetch=True):
    """
    Helper to run a SELECT query and return list of dict rows.
    """
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute(query, params or ())
    result = cursor.fetchall() if fetch else None
    cursor.close()
    conn.close()
    return result


def run_write(query, params=None):
    """
    Helper to run INSERT / UPDATE / DELETE. Returns lastrowid (for INSERT).
    """
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(query, params or ())
    conn.commit()
    last_id = cursor.lastrowid
    cursor.close()
    conn.close()
    return last_id
