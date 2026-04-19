from inference import NetFenceAI

# Initialize the AI Engine once
detector = NetFenceAI()

def final_scan(signal, is_open, duplicate, mac, vendor):
    # This calls the modular logic inside inference.py
    result = detector.analyze_network(signal, is_open, duplicate, mac, vendor)
    
    if result['level'] == "CRITICAL":
        return f"⚠️ {result['level']}: {result['alert']}"
    elif result['level'] == "WARNING":
        return f"🟡 {result['level']}: {result['alert']}"
    else:
        return f"✅ {result['level']}: {result['alert']}"

# Sunday Demo Test Case
# Signal -10 (Strong), Open (1), Duplicate (1), MAC mismatch (Apple prefix with TP-Link name)
print(final_scan(-10, 1, 1, "00:0A:95", "TP-Link"))