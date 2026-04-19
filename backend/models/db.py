import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(__file__), '..', 'netfence.db')


def get_db():
    """Get a connection to the SQLite database."""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    """Initialize the database with required tables."""
    conn = get_db()
    cursor = conn.cursor()
    
    # Create network_scans table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS network_scans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ssid TEXT,
            mac_address TEXT,
            encryption_type TEXT,
            signal_strength INTEGER,
            latitude REAL,
            longitude REAL,
            timestamp TEXT,
            is_flagged INTEGER DEFAULT 0
        )
    ''')
    
    # Create threat_zones table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS threat_zones (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ssid TEXT,
            mac_address TEXT,
            latitude REAL,
            longitude REAL,
            radius_meters REAL DEFAULT 50,
            threat_type TEXT,
            created_at TEXT
        )
    ''')
    
    conn.commit()
    conn.close()
    print("Database initialized successfully")


# Initialize database when module is imported
init_db()
