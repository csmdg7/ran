import joblib
import numpy as np

class NetFenceAI:
    def __init__(self, model_path='netfence_brain.pkl'):
        # Load the saved brain
        self.model = joblib.load(model_path)
        
    def check_mac_spoof(self, mac, claimed_vendor):
        """Hardware signature verification logic"""
        # Dictionary of common OUIs for the demo
        oui_table = {"00:0A:95": "Apple", "00:14:22": "Dell", "00:40:96": "Cisco"}
        prefix = mac[:8].upper()
        actual_vendor = oui_table.get(prefix, "Unknown")
        return actual_vendor.lower() != claimed_vendor.lower()

    def analyze_network(self, signal, is_open, is_duplicate, mac, vendor):
        """The main function the backend will call"""
        # AI Anomaly Detection
        features = np.array([[signal, is_open, is_duplicate]])
        prediction = self.model.predict(features) # Returns -1 for anomaly
        
        is_ai_anomaly = True if prediction[0] == -1 else False
        is_mac_anomaly = self.check_mac_spoof(mac, vendor)
        
        # Determine Threat Level
        if is_ai_anomaly and is_mac_anomaly:
            return {"level": "CRITICAL", "score": 9, "alert": "Possible Evil Twin detected!"}
        elif is_ai_anomaly or is_mac_anomaly:
            return {"level": "WARNING", "score": 5, "alert": "Suspicious network behavior."}
        else:
            return {"level": "SAFE", "score": 0, "alert": "Network looks secure."}

# Usage example for your teammate:
# detector = NetFenceAI()
# result = detector.analyze_network(-20, 1, 1, "00:0A:95", "TP-Link")