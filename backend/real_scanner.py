
# Install: pip install pywifi comtypes (Windows) or pip install pywifi (Linux/Mac)

import time
import requests
from pywifi import PyWiFi, const, Profile

VENDOR_OUI = {
    '00:0A:95': 'Apple',
    '00:14:22': 'Dell',
    '00:40:96': 'Cisco',
    '00:1A:70': 'Apple',
    '00:26:5E': 'Apple',
    '00:50:F4': 'Linksys',
    '00:1F:E2': 'Ubiquiti',
    '00:17:3F': 'Netgear',
    '00:22:B0': 'TP-Link',
    '00:25:86': 'TP-Link',
    '00:1D:7E': 'Asus',
    '00:19:DB': 'Asus',
    '00:12:17': 'NETGEAR',
    '00:06:5B': 'Netgate',
    '00:04:9F': 'Cisco',
    '00:60:B0': 'Cisco',
    '00:0C:F6': 'Linksys',
}

def resolve_vendor(mac_address):
    if not mac_address:
        return 'Unknown'
    prefix = mac_address.strip().upper().replace('-', ':')[:8]
    return VENDOR_OUI.get(prefix, 'Unknown')

VENDOR_OUI = {
    '00:0A:95': 'Apple',
    '00:14:22': 'Dell',
    '00:40:96': 'Cisco',
    '00:1A:70': 'Apple',
    '00:26:5E': 'Apple',
    '00:50:F4': 'Linksys',
    '00:1F:E2': 'Ubiquiti',
    '00:17:3F': 'Netgear',
    '00:22:B0': 'TP-Link',
    '00:25:86': 'TP-Link',
    '00:1D:7E': 'Asus',
    '00:19:DB': 'Asus',
    '00:12:17': 'NETGEAR',
    '00:06:5B': 'Netgate',
    '00:04:9F': 'Cisco',
    '00:60:B0': 'Cisco',
    '00:0C:F6': 'Linksys',
}

def resolve_vendor(mac_address):
    if not mac_address:
        return 'Unknown'
    prefix = mac_address.strip().upper().replace('-', ':')[:8]
    return VENDOR_OUI.get(prefix, 'Unknown')


def scan_and_upload():
    wifi = PyWiFi()
    iface = wifi.interfaces()[0]  # Use the first interface

    iface.scan()
    time.sleep(2)  # Wait for scan to complete
    results = iface.scan_results()

    # Hardcoded coordinates - CHANGE THESE TO YOUR CURRENT LOCATION
    latitude = 37.6213  # Example: San Francisco Airport
    longitude = -122.3790
    print(f"Using hardcoded coordinates: lat={latitude}, lon={longitude}")
    print("Please update the latitude and longitude variables in this script to your current location before running.")

    for network in results:
        ssid = network.ssid
        if not ssid:  # Skip empty SSIDs
            continue

        mac_address = network.bssid.upper()  # Format as AA:BB:CC:DD:EE:FF

        # Determine encryption type from AKM list
        akm_list = network.akm
        if getattr(const, 'AKM_TYPE_WPA3', None) in akm_list:
            encryption_type = "WPA3"
        elif const.AKM_TYPE_WPA2PSK in akm_list:
            encryption_type = "WPA2"
        elif const.AKM_TYPE_WPAPSK in akm_list:
            encryption_type = "WPA"
        elif const.AKM_TYPE_NONE in akm_list:
            encryption_type = "OPEN"
        else:
            encryption_type = "WEP"

        signal_strength = network.signal  # Raw signal value
        vendor = resolve_vendor(mac_address)

        # Prepare data
        data = {
            "ssid": ssid,
            "mac_address": mac_address,
            "vendor": vendor,
            "encryption_type": encryption_type,
            "signal_strength": signal_strength,
            "latitude": latitude,
            "longitude": longitude
        }

        # POST to API
        try:
            response = requests.post("http://localhost:5000/api/scan-upload", json=data)
            response.raise_for_status()
            result = response.json()

            if result.get('is_threat'):
                threat_type = result.get('threat_type', 'unknown')
                print(f"[THREAT: {threat_type}] {ssid}")
            else:
                print(f"[SAFE] {ssid}")

        except requests.RequestException as e:
            print(f"Error uploading {ssid}: {e}")

if __name__ == "__main__":
    print("Starting Wi-Fi scanner. Press Ctrl+C to stop.")
    try:
        while True:
            scan_and_upload()
            time.sleep(30)
    except KeyboardInterrupt:
        print("Scanner stopped.")