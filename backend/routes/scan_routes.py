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
    required_fields = ['ssid', 'mac_address', 'encryption_type', 'signal_strength', 'latitude', 'longitude', 'vendor']
    if not all(field in data for field in required_fields):
        return jsonify({'error': 'missing fields'}), 400

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute('SELECT COUNT(*) FROM network_scans WHERE ssid = ? AND mac_address = ?', (data['ssid'], data['mac_address']))
    row = cursor.fetchone()
    duplicate_count = int(row[0]) if row and row[0] is not None else 0
    is_duplicate_val = 1 if duplicate_count > 0 else 0

    # --- RUN YOUR AI BRAIN ---
    try:
        is_open_val = 1 if data['encryption_type'].lower() == 'open' else 0
        ai_result = net_ai.analyze_network(
            ssid=data['ssid'],
            signal=data['signal_strength'],
            is_open=is_open_val,
            is_duplicate=is_duplicate_val,
            mac=data['mac_address'],
            vendor=data.get('vendor', 'Unknown'),
            latitude=data['latitude'],
            longitude=data['longitude']
        )
        is_threat = True if ai_result['level'] in ['CRITICAL', 'WARNING'] else False
        threat_type = ai_result['level']
        ai_score = ai_result['score']
        alert_text = ai_result.get('alert', '')
    except Exception as e:
        print(f"Error in AI analysis: {e}")
        is_threat = False
        threat_type = 'ERROR'
        ai_score = 0
        alert_text = 'AI analysis failed.'
    # ---------------------------

    data['timestamp'] = datetime.utcnow().isoformat()

    cursor.execute('''
        INSERT INTO network_scans (ssid, mac_address, vendor, encryption_type, signal_strength, latitude, longitude, timestamp, ai_score, alert_text)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', (
        data['ssid'],
        data['mac_address'],
        data.get('vendor', 'Unknown'),
        data['encryption_type'],
        data['signal_strength'],
        data['latitude'],
        data['longitude'],
        data['timestamp'],
        ai_score,
        alert_text
    ))

    scan_id = cursor.lastrowid

    if is_threat:
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
        cursor.execute('UPDATE network_scans SET is_flagged = 1 WHERE id = ?', (scan_id,))

    conn.commit()
    conn.close()

    return jsonify({
        'received': True,
        'threat_detected': is_threat,
        'threat_type': threat_type,
        'ai_score': ai_score,
        'alert': alert_text,
        'scan_id': scan_id,
        'message': 'Scan processed successfully'
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