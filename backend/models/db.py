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
            vendor TEXT,
            encryption_type TEXT,
            signal_strength INTEGER,
            latitude REAL,
            longitude REAL,
            timestamp TEXT,
            is_flagged INTEGER DEFAULT 0,
            ai_score INTEGER DEFAULT 0,
            alert_text TEXT
        )
    ''')
    
    # Add missing columns if database already exists
    def _add_column_if_missing(table, column_def):
        try:
            cursor.execute(f'ALTER TABLE {table} ADD COLUMN {column_def}')
        except Exception:
            pass

    _add_column_if_missing('network_scans', 'vendor TEXT')
    _add_column_if_missing('network_scans', 'ai_score INTEGER DEFAULT 0')
    _add_column_if_missing('network_scans', 'alert_text TEXT')

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
