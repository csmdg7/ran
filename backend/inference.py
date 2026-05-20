import joblib
import numpy as np
import os
import logging
from collections import defaultdict
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)

class NetFenceAI:
    def __init__(self, model_path='netfence_brain.pkl'):
        """Initialize NetFenceAI with model loading and edge state."""
        self.model = None
        self.model_path = model_path
        self.recent_networks = defaultdict(list)
        self.mac_history = {}

        try:
            if os.path.exists(model_path):
                self.model = joblib.load(model_path)
                logger.info(f"Model loaded successfully from {model_path}")
            else:
                logger.warning(f"Model file not found at {model_path}. Using rule-based detection only.")
                self.model = None
        except Exception as e:
            logger.error(f"Failed to load model from {model_path}: {e}")
            self.model = None

    def _haversine(self, lat1, lon1, lat2, lon2):
        R = 6371.0
        dlat = np.radians(lat2 - lat1)
        dlon = np.radians(lon2 - lon1)
        a = np.sin(dlat / 2) ** 2 + np.cos(np.radians(lat1)) * np.cos(np.radians(lat2)) * np.sin(dlon / 2) ** 2
        return R * 2 * np.arcsin(np.sqrt(a))

    def _prune_recent_records(self, ssid):
        cutoff = datetime.utcnow() - timedelta(minutes=10)
        self.recent_networks[ssid] = [entry for entry in self.recent_networks[ssid] if entry['timestamp'] >= cutoff]

    def _normalize_score(self, score):
        return int(max(0, min(10, score)))

    def check_mac_spoof(self, mac, claimed_vendor):
        oui_table = {
            "00:0A:95": "Apple",
            "00:14:22": "Dell",
            "00:40:96": "Cisco",
            "00:1A:70": "Apple",
            "00:26:5E": "Apple",
            "00:50:F4": "Linksys",
            "00:1F:E2": "Ubiquiti",
            "00:17:3F": "Netgear",
            "00:22:B0": "TP-Link",
            "00:25:86": "TP-Link",
            "00:1D:7E": "Asus",
            "00:19:DB": "Asus",
            "00:12:17": "NETGEAR",
            "00:06:5B": "Netgate",
            "00:04:9F": "Cisco",
            "00:60:B0": "Cisco",
            "00:0C:F6": "Linksys",
        }

        try:
            prefix = mac[:8].upper()
            actual_vendor = oui_table.get(prefix, "Unknown")
            if not claimed_vendor:
                return False
            is_spoofed = actual_vendor.lower() != claimed_vendor.lower()
            if prefix.startswith('02'):
                return True
            return is_spoofed
        except Exception as e:
            logger.warning(f"Error checking MAC spoof for {mac}: {e}")
            return False

    def analyze_network(self, ssid, signal, is_open, is_duplicate, mac, vendor, latitude, longitude):
        score = 0
        alerts = []
        ssid = ssid or 'Unknown'
        mac = (mac or '').upper()
        vendor = vendor or 'Unknown'

        if is_open == 1:
            score += 9
            alerts.append('Open network detected - no encryption!')

        if mac.startswith('02:'):
            score += 8
            alerts.append('Locally administered MAC detected; possible Evil Twin.')

        if self.check_mac_spoof(mac, vendor):
            score += 5
            alerts.append('Vendor claim does not match observed MAC OUI.')

        self._prune_recent_records(ssid)
        existing_macs = {entry['mac'] for entry in self.recent_networks[ssid]}
        if mac and existing_macs and mac not in existing_macs:
            score += 4
            alerts.append('New MAC seen for an existing SSID in recent scans.')

        if mac in self.mac_history:
            last = self.mac_history[mac]
            distance_km = float(self._haversine(latitude, longitude, last['lat'], last['lon']))
            if distance_km > 0.5:
                score += 6
                alerts.append('Location drift detected for the same MAC address.')

        if self.model is not None:
            features = np.array([[signal, is_open, is_duplicate]])
            try:
                prediction = self.model.predict(features)
                if prediction[0] == -1:
                    score += 6
                    alerts.append('ML anomaly detected in RF pattern.')
            except Exception as e:
                logger.warning(f"Model prediction failed: {e}")

        if is_duplicate == 1 and 'Open network detected - no encryption!' not in alerts:
            score += 1
            alerts.append('Repeated presence of this network was observed.')

        final_score = self._normalize_score(score)
        if final_score >= 8:
            level = 'CRITICAL'
        elif final_score >= 4:
            level = 'WARNING'
        else:
            level = 'SAFE'

        if not alerts:
            alerts.append('Network appears secure. No rule-based or ML anomalies found.')

        self.recent_networks[ssid].append({
            'mac': mac,
            'timestamp': datetime.utcnow(),
            'lat': latitude,
            'lon': longitude,
            'signal': signal,
        })
        self.mac_history[mac] = {'lat': latitude, 'lon': longitude, 'timestamp': datetime.utcnow()}

        return {
            'level': level,
            'score': final_score,
            'alert': ' '.join(alerts),
        }
