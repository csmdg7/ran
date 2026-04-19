from inference import NetFenceAI

# 1. Initialize your AI
detector = NetFenceAI()

# 2. Mock a "Teammate Scan" (Data coming from their Backend)
test_data = {
    "signal": -20,         # Very strong (Suspicious)
    "is_open": 1,          # No password (Risk)
    "is_duplicate": 1,     # Name matches a known safe network (Evil Twin!)
    "mac": "00:0A:95",     # Apple MAC
    "vendor": "TP-Link"    # BUT vendor says TP-Link! (Hardware Mismatch)
}

# 3. Run the test
result = detector.analyze_network(
    test_data['signal'], 
    test_data['is_open'], 
    test_data['is_duplicate'], 
    test_data['mac'], 
    test_data['vendor']
)

print(f"AI Decision: {result['level']}")
print(f"Reason: {result['alert']}")