from flask import Blueprint, jsonify, request
from datetime import datetime
from models.db import get_db
from ml.detector import run_threat_detection

scan_bp = Blueprint('scan_bp', __name__, url_prefix='/api')


@scan_bp.route('/scan-upload', methods=['POST'])
def scan_upload():
    """Upload Wi-Fi scan data and perform threat detection."""
    data = request.get_json()

    # Validate required fields
    required_fields = ['ssid', 'mac_address', 'encryption_type', 'signal_strength', 'latitude', 'longitude']
    if not all(field in data for field in required_fields):
        return jsonify({'error': 'missing fields'}), 400

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

    # Run threat detection
    threat_result = run_threat_detection(data)

    if threat_result['is_threat']:
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
            threat_result['threat_type'],
            data['timestamp']
        ))

        # Update is_flagged on the scan
        cursor.execute('UPDATE network_scans SET is_flagged = 1 WHERE id = ?', (scan_id,))

    conn.commit()
    conn.close()

    return jsonify({
        'received': True,
        'threat_detected': threat_result['is_threat'],
        'threat_type': threat_result['threat_type'],
        'scan_id': scan_id
    }), 200


@scan_bp.route('/networks', methods=['GET'])
def get_networks():
    """Get list of detected rogue networks."""
    # TODO: Implement network scanning and detection
    return jsonify({
        'status': 'success',
        'networks': []
    }), 200


@scan_bp.route('/start', methods=['POST'])
def start_scan():
    """Start a new Wi-Fi scan."""
    # TODO: Implement Wi-Fi scanning logic
    return jsonify({
        'status': 'success',
        'message': 'Scan started'
    }), 200


@scan_bp.route('/status', methods=['GET'])
def scan_status():
    """Get current scan status."""
    # TODO: Implement scan status tracking
    return jsonify({
        'status': 'idle',
        'progress': 0
    }), 200
