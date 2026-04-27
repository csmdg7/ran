from flask import Blueprint, jsonify, request
from datetime import datetime
from models.db import get_db

# --- YOUR AI INTEGRATION ---
from inference import NetFenceAI
net_ai = NetFenceAI()
# ---------------------------

scan_bp = Blueprint('scan_bp', __name__, url_prefix='/api')

@scan_bp.route('/scan', methods=['POST'])
@scan_bp.route('/scan-upload', methods=['POST'])
def scan_upload():
    """Upload Wi-Fi scan data and perform REAL AI threat detection."""
    data = request.get_json()

    # Validate required fields
    required_fields = ['ssid', 'mac_address', 'encryption_type', 'signal_strength', 'latitude', 'longitude']
    if not all(field in data for field in required_fields):
        return jsonify({'error': 'missing fields'}), 400

    # --- RUN YOUR AI BRAIN ---
    # Convert 'Open' strings to 1/0 for your model
    is_open_val = 1 if data['encryption_type'].lower() == 'open' else 0
    
    # Analyze using your Isolation Forest + MAC Check
    ai_result = net_ai.analyze_network(
        signal=data['signal_strength'],
        is_open=is_open_val,
        is_duplicate=0, # Defaulting to 0 for single scan
        mac=data['mac_address'],
        vendor=data.get('vendor', 'Unknown')
    )
    
    # Determine if it's a threat based on your AI 'level'
    is_threat = True if ai_result['level'] in ['High', 'Medium'] else False
    threat_type = ai_result['alert']
    # ---------------------------

    # Add timestamp
    data['timestamp'] = datetime.utcnow().isoformat()

    # Insert scan into database
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute('''
        INSERT INTO network_scans (ssid, mac_address, encryption_type, signal_strength, latitude, longitude, timestamp)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ''', (
        data['ssid'],
        data['mac_address'],
        data['encryption_type'],
        data['signal_strength'],
        data['latitude'],
        data['longitude'],
        data['timestamp']
    ))

    scan_id = cursor.lastrowid

    if is_threat:
        # Insert into threat_zones
        cursor.execute('''
            INSERT INTO threat_zones (ssid, mac_address, latitude, longitude, radius_meters, threat_type, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', (
            data['ssid'],
            data['mac_address'],
            data['latitude'],
            data['longitude'],
            50.0,
            threat_type,
            data['timestamp']
        ))

        # Update is_flagged on the scan
        cursor.execute('UPDATE network_scans SET is_flagged = 1 WHERE id = ?', (scan_id,))

    conn.commit()
    conn.close()

    return jsonify({
        'received': True,
        'threat_detected': is_threat,
        'threat_type': threat_type,
        'ai_score': ai_result['score'],
        'scan_id': scan_id
    }), 200

@scan_bp.route('/health', methods=['GET'])
def api_health():
    return jsonify({'status': 'ok'}), 200

@scan_bp.route('/networks', methods=['GET'])
def get_networks():
    return jsonify({'status': 'success', 'networks': []}), 200

@scan_bp.route('/start', methods=['POST'])
def start_scan():
    return jsonify({'status': 'success', 'message': 'Scan started'}), 200

@scan_bp.route('/status', methods=['GET'])
def scan_status():
    return jsonify({'status': 'idle', 'progress': 0}), 200