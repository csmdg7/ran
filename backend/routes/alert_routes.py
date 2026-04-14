from flask import Blueprint, jsonify, request
import math
from datetime import datetime
from models.db import get_db

alert_bp = Blueprint('alert_bp', __name__, url_prefix='/api')


def haversine(lat1, lon1, lat2, lon2):
    """Calculate the great circle distance between two points on Earth."""
    R = 6371  # Earth's radius in kilometers
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat/2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon/2)**2
    return R * 2 * math.asin(math.sqrt(a))


@alert_bp.route('/threats', methods=['GET'])
def get_threats():
    """Get all threat zones."""
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute('SELECT id, ssid, latitude, longitude, radius_meters, threat_type, created_at FROM threat_zones')
    threats = cursor.fetchall()

    conn.close()

    # Convert to list of dictionaries
    threat_list = []
    for threat in threats:
        threat_list.append({
            'id': threat['id'],
            'ssid': threat['ssid'],
            'latitude': threat['latitude'],
            'longitude': threat['longitude'],
            'radius_meters': threat['radius_meters'],
            'threat_type': threat['threat_type'],
            'created_at': threat['created_at']
        })

    return jsonify(threat_list), 200


@alert_bp.route('/threats/nearby', methods=['GET'])
def get_nearby_threats():
    """Get threats within a specified radius."""
    try:
        lat = float(request.args.get('lat'))
        lon = float(request.args.get('lon'))
        radius_km = float(request.args.get('radius_km', 1.0))
    except (TypeError, ValueError):
        return jsonify({'error': 'Invalid or missing lat/lon parameters'}), 400

    if lat is None or lon is None:
        return jsonify({'error': 'lat and lon parameters are required'}), 400

    conn = get_db()
    cursor = conn.cursor()

    cursor.execute('SELECT id, ssid, latitude, longitude, radius_meters, threat_type, created_at FROM threat_zones')
    threats = cursor.fetchall()

    conn.close()

    # Filter threats within radius and calculate distances
    nearby_threats = []
    for threat in threats:
        distance = haversine(lat, lon, threat['latitude'], threat['longitude'])
        if distance <= radius_km:
            nearby_threats.append({
                'id': threat['id'],
                'ssid': threat['ssid'],
                'latitude': threat['latitude'],
                'longitude': threat['longitude'],
                'radius_meters': threat['radius_meters'],
                'threat_type': threat['threat_type'],
                'created_at': threat['created_at'],
                'distance_km': round(distance, 3)
            })

    return jsonify(nearby_threats), 200


@alert_bp.route('', methods=['GET'])
def get_alerts():
    """Get all alerts."""
    # TODO: Implement fetch alerts from database
    return jsonify({
        'status': 'success',
        'alerts': []
    }), 200


@alert_bp.route('/<int:alert_id>', methods=['GET'])
def get_alert(alert_id):
    """Get a specific alert by ID."""
    # TODO: Implement fetch single alert
    return jsonify({
        'status': 'success',
        'alert': None
    }), 200


@alert_bp.route('/<int:alert_id>/read', methods=['PUT'])
def mark_alert_read(alert_id):
    """Mark an alert as read."""
    # TODO: Implement mark alert as read
    return jsonify({
        'status': 'success',
        'message': 'Alert marked as read'
    }), 200


@alert_bp.route('', methods=['DELETE'])
def clear_alerts():
    """Clear all alerts."""
    # TODO: Implement clear alerts
    return jsonify({
        'status': 'success',
        'message': 'All alerts cleared'
    }), 200


# WARNING: Remove or protect this endpoint before any production deployment
@alert_bp.route('/demo/seed-threat', methods=['POST'])
def seed_threat():
    """Seed a threat zone for demo purposes."""
    data = request.get_json()

    # Validate required fields
    required_fields = ['ssid', 'mac_address', 'latitude', 'longitude', 'threat_type']
    if not all(field in data for field in required_fields):
        return jsonify({'error': 'Missing required fields'}), 400

    # Insert into threat_zones
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute('''
        INSERT INTO threat_zones (ssid, mac_address, latitude, longitude, radius_meters, threat_type, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ''', (
        data['ssid'],
        data['mac_address'],
        data['latitude'],
        data['longitude'],
        75,
        data['threat_type'],
        datetime.utcnow().isoformat()
    ))

    threat_id = cursor.lastrowid
    conn.commit()
    conn.close()

    return jsonify({'seeded': True, 'id': threat_id}), 200


@alert_bp.route('/stats', methods=['GET'])
def get_stats():
    """Get statistics about scans and threats."""
    conn = get_db()
    cursor = conn.cursor()

    # Total scans
    cursor.execute('SELECT COUNT(*) FROM network_scans')
    total_scans = cursor.fetchone()[0]

    # Total threats
    cursor.execute('SELECT COUNT(*) FROM threat_zones')
    total_threats = cursor.fetchone()[0]

    # Threat breakdown
    cursor.execute('SELECT threat_type, COUNT(*) FROM threat_zones GROUP BY threat_type')
    threat_rows = cursor.fetchall()
    threat_breakdown = {row['threat_type']: row[1] for row in threat_rows}

    # Latest threat
    cursor.execute('SELECT ssid, latitude, longitude, threat_type, created_at FROM threat_zones ORDER BY created_at DESC LIMIT 1')
    latest_row = cursor.fetchone()
    latest_threat = None
    if latest_row:
        latest_threat = {
            'ssid': latest_row['ssid'],
            'latitude': latest_row['latitude'],
            'longitude': latest_row['longitude'],
            'threat_type': latest_row['threat_type'],
            'created_at': latest_row['created_at']
        }

    conn.close()

    return jsonify({
        'total_scans': total_scans,
        'total_threats': total_threats,
        'threat_breakdown': threat_breakdown,
        'latest_threat': latest_threat
    }), 200
