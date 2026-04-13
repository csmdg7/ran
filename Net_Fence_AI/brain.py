# Add this "Extraordinary" feature: OUI/MAC Validation
def check_mac_anomaly(mac_address, claimed_vendor):
    # Real-world logic: MAC addresses have a 3-byte prefix (OUI) 
    # that identifies the manufacturer (e.g., Apple, Cisco).
    # If a hacker spoofs a MAC but keeps a generic OUI, we catch them.
    
    # Simple Demo Logic:
    known_vendors = {
        "00:0A:95": "Apple",
        "00:14:22": "Dell",
        "00:40:96": "Cisco"
    }
    
    prefix = mac_address[:8].upper()
    actual_vendor = known_vendors.get(prefix, "Unknown")
    
    if claimed_vendor != actual_vendor:
        return True # Anomaly found!
    return False

# Integrated check for your teammate
def final_scan(signal, encryption, duplicate, mac, vendor):
    ai_result = check_network(signal, encryption, duplicate)
    mac_anomaly = check_mac_anomaly(mac, vendor)
    
    if ai_result == "THREAT DETECTED" or mac_anomaly:
        return "⚠️ CRITICAL: Rogue Device/Location Detected!"
    return "✅ Network Secure"

print(final_scan(-10, 0, 1, "00:0A:95", "TP-Link")) # This will trigger an anomaly!