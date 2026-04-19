# Net-Fence AI Threat Detection Module
# This module contains ML-based threat detection algorithms using IsolationForest
# for identifying potentially malicious Wi-Fi networks and security threats.

from datetime import datetime, timedelta
import numpy as np
from sklearn.ensemble import IsolationForest
from models.db import get_db


def _rule_based(scan_data):
    """
    Fallback rule-based threat detection logic.
    Used when insufficient historical data is available for ML training.
    """
    encryption_type = scan_data.get('encryption_type', '').upper()
    mac_address = scan_data.get('mac_address', '')

    if encryption_type == 'OPEN':
        return {"is_threat": True, "threat_type": "open_network"}
    elif encryption_type == 'WEP':
        return {"is_threat": True, "threat_type": "weak_encryption"}
    elif mac_address.startswith('02:'):
        return {"is_threat": True, "threat_type": "mac_spoof"}
    else:
        return {"is_threat": False, "threat_type": None}


def _get_encryption_score(encryption_type):
    """Convert encryption type to numerical score."""
    enc_map = {
        'OPEN': 0,
        'WEP': 1,
        'WPA': 2,
        'WPA2': 3
    }
    return enc_map.get(encryption_type.upper(), 2)  # Default to WPA score


def _get_mac_random_score(mac_address):
    """Check if MAC address indicates randomization."""
    return 1 if mac_address.startswith('02:') else 0


def run_threat_detection(scan_data):
    """
    Run threat detection on scan data using IsolationForest ML model.
    Falls back to rule-based logic if insufficient historical data.

    Args:
        scan_data (dict): Dictionary containing scan information including:
            - ssid: Network name
            - mac_address: MAC address
            - encryption_type: Encryption type (OPEN, WEP, WPA2, etc.)
            - signal_strength: Signal strength in dBm
            - latitude: GPS latitude
            - longitude: GPS longitude
            - timestamp: Scan timestamp

    Returns:
        dict: {
            'is_threat': bool,
            'threat_type': str or None
        }
    """
    # Evil twin detection - highest priority threat
    conn = get_db()
    cursor = conn.cursor()
    current_time = datetime.now()
    ten_minutes_ago = current_time - timedelta(minutes=10)
    cursor.execute('''
        SELECT * FROM network_scans
        WHERE ssid = ? AND mac_address != ? AND timestamp > ?
    ''', (scan_data['ssid'], scan_data['mac_address'], ten_minutes_ago.isoformat()))
    evil_twin_rows = cursor.fetchall()
    conn.close()
    if evil_twin_rows:
        return {"is_threat": True, "threat_type": "evil_twin"}
    # Check for rule-based threats
    rule_result = _rule_based(scan_data)
    if rule_result['is_threat']:
        return rule_result
    # Query historical data from database
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute('''
        SELECT encryption_type, signal_strength, mac_address
        FROM network_scans
        ORDER BY id DESC
        LIMIT 200
    ''')

    historical_scans = cursor.fetchall()
    conn.close()

    # Fall back to rule-based if insufficient data
    if len(historical_scans) < 10:
        return _rule_based(scan_data)

    # Build feature matrix from historical data
    features = []
    for scan in historical_scans:
        enc_score = _get_encryption_score(scan['encryption_type'])
        signal_strength = scan['signal_strength']
        mac_random_score = _get_mac_random_score(scan['mac_address'])
        features.append([enc_score, signal_strength, mac_random_score])

    X_train = np.array(features)

    # Train IsolationForest model
    model = IsolationForest(contamination=0.1, random_state=42)
    model.fit(X_train)

    # Extract features from new scan data
    new_enc_score = _get_encryption_score(scan_data.get('encryption_type', ''))
    new_signal_strength = scan_data.get('signal_strength', 0)
    new_mac_random_score = _get_mac_random_score(scan_data.get('mac_address', ''))

    X_new = np.array([[new_enc_score, new_signal_strength, new_mac_random_score]])

    # Make prediction
    prediction = model.predict(X_new)[0]

    # If not an anomaly (prediction == 1), return no threat
    if prediction == 1:
        return {"is_threat": False, "threat_type": None}

    # Anomaly detected (prediction == -1), determine threat type
    if new_enc_score <= 1:  # OPEN or WEP
        threat_type = "weak_encryption"
    elif new_mac_random_score == 1:  # MAC starts with 02:
        threat_type = "mac_spoof"
    else:
        threat_type = "suspicious_network"

    return {"is_threat": True, "threat_type": threat_type}