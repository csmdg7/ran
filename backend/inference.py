import joblib
import numpy as np
import os
import logging

logger = logging.getLogger(__name__)

class NetFenceAI:
    def __init__(self, model_path='netfence_brain.pkl'):
        """Initialize NetFenceAI with model loading and error handling."""
        self.model = None
        self.model_path = model_path
        
        # Try to load the model
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
        
    def check_mac_spoof(self, mac, claimed_vendor):
        """Hardware signature verification logic with expanded OUI table."""
        # Expanded OUI (Organizationally Unique Identifier) table
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
            is_spoofed = actual_vendor.lower() != claimed_vendor.lower()
            
            if is_spoofed and prefix.startswith('02'):
                # Locally administered MAC address - suspicious
                return True
            return is_spoofed
        except Exception as e:
            logger.warning(f"Error checking MAC spoof for {mac}: {e}")
            return False

    def analyze_network(self, signal, is_open, is_duplicate, mac, vendor):
        """Analyze network with AI model or fallback to rule-based detection."""
        try:
            # Rule-based detection (always applied)
            if is_open == 1:
                return {"level": "CRITICAL", "score": 9, "alert": "Open network detected - no encryption!"}
            
            if mac.startswith('02:'):
                return {"level": "CRITICAL", "score": 8, "alert": "Suspicious MAC address - possible Evil Twin!"}
            
            # AI-based anomaly detection (if model is available)
            if self.model is not None:
                features = np.array([[signal, is_open, is_duplicate]])
                try:
                    prediction = self.model.predict(features)
                    is_ai_anomaly = True if prediction[0] == -1 else False
                    
                    if is_ai_anomaly:
                        return {"level": "WARNING", "score": 5, "alert": "Suspicious network behavior detected."}
                except Exception as e:
                    logger.warning(f"Model prediction failed: {e}")
            
            # Check MAC spoof
            is_mac_anomaly = self.check_mac_spoof(mac, vendor)
            if is_mac_anomaly:
                return {"level": "WARNING", "score": 4, "alert": "MAC address mismatch with vendor."}
            
            # If we get here, network looks safe
            return {"level": "SAFE", "score": 0, "alert": "Network looks secure."}
            
        except Exception as e:
            logger.error(f"Error in analyze_network: {e}")
            return {"level": "SAFE", "score": 0, "alert": "Analysis error - defaulting to safe."}