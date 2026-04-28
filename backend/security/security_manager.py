"""
Security utilities for Net-Fence AI backend
Handles encryption, validation, and security best practices
"""

from cryptography.fernet import Fernet
from marshmallow import Schema, fields, validate, ValidationError
import os
import re
from typing import Dict, Any

# Initialize encryption key from environment or generate one
ENCRYPTION_KEY = os.getenv('ENCRYPTION_KEY')
if not ENCRYPTION_KEY:
    ENCRYPTION_KEY = Fernet.generate_key()
    print("WARNING: No ENCRYPTION_KEY in environment. Generated temporary key.")

cipher_suite = Fernet(ENCRYPTION_KEY)


class SecurityManager:
    """Centralized security management"""
    
    @staticmethod
    def encrypt_data(data: str) -> str:
        """Encrypt sensitive data"""
        try:
            return cipher_suite.encrypt(data.encode()).decode()
        except Exception as e:
            print(f"Encryption error: {e}")
            return data
    
    @staticmethod
    def decrypt_data(encrypted_data: str) -> str:
        """Decrypt sensitive data"""
        try:
            return cipher_suite.decrypt(encrypted_data.encode()).decode()
        except Exception as e:
            print(f"Decryption error: {e}")
            return encrypted_data
    
    @staticmethod
    def sanitize_input(value: str, max_length: int = 255) -> str:
        """Sanitize user input to prevent injection attacks"""
        if not isinstance(value, str):
            return ""
        
        # Limit length
        value = value[:max_length]
        
        # Remove potentially dangerous characters
        dangerous_chars = ['<', '>', '"', "'", ';', '\\', '/', '--']
        for char in dangerous_chars:
            value = value.replace(char, '')
        
        # Remove extra whitespace
        value = ' '.join(value.split())
        
        return value
    
    @staticmethod
    def validate_mac_address(mac: str) -> bool:
        """Validate MAC address format"""
        mac_pattern = r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$'
        return bool(re.match(mac_pattern, mac))
    
    @staticmethod
    def validate_coordinates(lat: float, lon: float) -> bool:
        """Validate latitude and longitude"""
        try:
            lat = float(lat)
            lon = float(lon)
            return -90 <= lat <= 90 and -180 <= lon <= 180
        except (ValueError, TypeError):
            return False
    
    @staticmethod
    def validate_ssid(ssid: str) -> bool:
        """Validate SSID format"""
        ssid = ssid.strip()
        return 0 < len(ssid) <= 32  # Standard SSID length


class ScanSchema(Schema):
    """Marshmallow schema for scan data validation"""
    ssid = fields.Str(
        required=True,
        validate=validate.Length(min=1, max=32),
        error_messages={'required': 'SSID is required'}
    )
    mac_address = fields.Str(
        required=True,
        error_messages={'required': 'MAC address is required'}
    )
    encryption_type = fields.Str(
        required=True,
        validate=validate.OneOf(['WPA2', 'WEP', 'Open', 'WPA3']),
        error_messages={'required': 'Encryption type is required'}
    )
    signal_strength = fields.Int(
        required=True,
        validate=validate.Range(min=-100, max=0),
        error_messages={'required': 'Signal strength is required'}
    )
    latitude = fields.Float(
        required=True,
        validate=validate.Range(min=-90, max=90),
        error_messages={'required': 'Valid latitude is required'}
    )
    longitude = fields.Float(
        required=True,
        validate=validate.Range(min=-180, max=180),
        error_messages={'required': 'Valid longitude is required'}
    )


class LocationSchema(Schema):
    """Marshmallow schema for location query validation"""
    lat = fields.Float(
        required=True,
        validate=validate.Range(min=-90, max=90)
    )
    lon = fields.Float(
        required=True,
        validate=validate.Range(min=-180, max=180)
    )
    radius = fields.Float(
        missing=1.0,
        validate=validate.Range(min=0.1, max=100)
    )


def validate_scan_data(data: Dict[str, Any]) -> Dict[str, Any]:
    """Validate scan data using schema"""
    schema = ScanSchema()
    try:
        result = schema.load(data)
        # Sanitize SSID
        result['ssid'] = SecurityManager.sanitize_input(result['ssid'], max_length=32)
        return result
    except ValidationError as err:
        raise ValueError(f"Invalid scan data: {err.messages}")


def validate_location_data(data: Dict[str, Any]) -> Dict[str, Any]:
    """Validate location query data"""
    schema = LocationSchema()
    try:
        return schema.load(data)
    except ValidationError as err:
        raise ValueError(f"Invalid location data: {err.messages}")
