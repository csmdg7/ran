import requests

BASE_URL = "http://localhost:5000"

def test_health():
    try:
        response = requests.get(f"{BASE_URL}/health")
        data = response.json()
        if response.status_code == 200 and data.get("status") == "ok":
            print("PASS: GET /health - Status OK")
            return True
        else:
            print(f"FAIL: GET /health - Response: {data}")
            return False
    except Exception as e:
        print(f"FAIL: GET /health - Error: {e}")
        return False

def test_scan_wpa2():
    data = {
        "ssid": "TestWPA2",
        "mac_address": "AA:BB:CC:DD:EE:FF",
        "encryption_type": "WPA2",
        "signal_strength": -50,
        "latitude": 37.7749,
        "longitude": -122.4194
    }
    try:
        response = requests.post(f"{BASE_URL}/api/scan-upload", json=data)
        result = response.json()
        if response.status_code == 200 and not result.get("threat_detected"):
            print("PASS: POST /api/scan-upload (WPA2) - No threat detected")
            return True
        else:
            print(f"FAIL: POST /api/scan-upload (WPA2) - Response: {result}")
            return False
    except Exception as e:
        print(f"FAIL: POST /api/scan-upload (WPA2) - Error: {e}")
        return False

def test_scan_open():
    data = {
        "ssid": "TestOpen",
        "mac_address": "BB:BB:CC:DD:EE:FF",
        "encryption_type": "OPEN",
        "signal_strength": -60,
        "latitude": 37.7749,
        "longitude": -122.4194
    }
    try:
        response = requests.post(f"{BASE_URL}/api/scan-upload", json=data)
        result = response.json()
        if response.status_code == 200 and result.get("threat_detected") and result.get("threat_type") == "open_network":
            print("PASS: POST /api/scan-upload (OPEN) - Open network threat detected")
            return True
        else:
            print(f"FAIL: POST /api/scan-upload (OPEN) - Response: {result}")
            return False
    except Exception as e:
        print(f"FAIL: POST /api/scan-upload (OPEN) - Error: {e}")
        return False

def test_scan_mac_spoof():
    data = {
        "ssid": "TestSpoof",
        "mac_address": "02:BB:CC:DD:EE:FF",
        "encryption_type": "WPA2",
        "signal_strength": -55,
        "latitude": 37.7749,
        "longitude": -122.4194
    }
    try:
        response = requests.post(f"{BASE_URL}/api/scan-upload", json=data)
        result = response.json()
        if response.status_code == 200 and result.get("threat_detected"):
            print("PASS: POST /api/scan-upload (MAC spoof) - Threat detected")
            return True
        else:
            print(f"FAIL: POST /api/scan-upload (MAC spoof) - Response: {result}")
            return False
    except Exception as e:
        print(f"FAIL: POST /api/scan-upload (MAC spoof) - Error: {e}")
        return False

def test_get_threats():
    try:
        response = requests.get(f"{BASE_URL}/api/threats")
        data = response.json()
        if response.status_code == 200 and isinstance(data, list) and len(data) >= 1:
            print("PASS: GET /api/threats - Returned list with at least 1 item")
            return True
        else:
            print(f"FAIL: GET /api/threats - Response: {data}")
            return False
    except Exception as e:
        print(f"FAIL: GET /api/threats - Error: {e}")
        return False

def test_nearby_threats():
    try:
        response = requests.get(f"{BASE_URL}/api/threats/nearby?lat=37.7749&lon=-122.4194&radius_km=50")
        data = response.json()
        if response.status_code == 200 and isinstance(data, list):
            has_distance = all('distance_km' in item for item in data)
            if has_distance:
                print("PASS: GET /api/threats/nearby - All results have distance_km field")
                return True
            else:
                print(f"FAIL: GET /api/threats/nearby - Missing distance_km in some results: {data}")
                return False
        else:
            print(f"FAIL: GET /api/threats/nearby - Response: {data}")
            return False
    except Exception as e:
        print(f"FAIL: GET /api/threats/nearby - Error: {e}")
        return False

def test_stats():
    try:
        response = requests.get(f"{BASE_URL}/api/stats")
        data = response.json()
        if response.status_code == 200 and data.get("total_scans", 0) > 0 and data.get("total_threats", 0) > 0:
            print("PASS: GET /api/stats - total_scans > 0 and total_threats > 0")
            return True
        else:
            print(f"FAIL: GET /api/stats - Response: {data}")
            return False
    except Exception as e:
        print(f"FAIL: GET /api/stats - Error: {e}")
        return False

if __name__ == "__main__":
    tests = [
        test_health,
        test_scan_wpa2,
        test_scan_open,
        test_scan_mac_spoof,
        test_get_threats,
        test_nearby_threats,
        test_stats
    ]

    passed = 0
    for test in tests:
        if test():
            passed += 1

    print(f"\n{passed}/7 tests passed.")