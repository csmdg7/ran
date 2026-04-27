import requests
from functools import lru_cache
from typing import Dict, Tuple
import logging

logger = logging.getLogger(__name__)

class OSMService:
    """Service for OpenStreetMap/Nominatim integration"""
    
    NOMINATIM_BASE_URL = "https://nominatim.openstreetmap.org"
    
    @staticmethod
    @lru_cache(maxsize=256)
    def get_place_name(latitude: float, longitude: float) -> str:
        """
        Get place name from coordinates using reverse geocoding via Nominatim.
        Results are cached for performance.
        """
        try:
            url = f"{OSMService.NOMINATIM_BASE_URL}/reverse"
            params = {
                'format': 'json',
                'lat': latitude,
                'lon': longitude,
                'zoom': 18,
                'addressdetails': 1
            }
            headers = {'User-Agent': 'Net-Fence-AI/1.0'}
            
            response = requests.get(url, params=params, headers=headers, timeout=5)
            response.raise_for_status()
            
            data = response.json()
            
            # Extract place name from response
            if 'address' in data:
                address = data['address']
                parts = []
                
                # Build address parts in order of priority
                if 'road' in address:
                    parts.append(address['road'])
                if 'city' in address:
                    parts.append(address['city'])
                elif 'suburb' in address:
                    parts.append(address['suburb'])
                if 'country' in address and address['country'] != 'India':
                    parts.append(address['country'])
                
                if parts:
                    return ', '.join(parts)
            
            # Fallback to display name
            if 'name' in data:
                return data['name']
            
            return f"{latitude:.4f}, {longitude:.4f}"
            
        except Exception as e:
            logger.warning(f"Error getting place name for {latitude}, {longitude}: {e}")
            return f"{latitude:.4f}, {longitude:.4f}"
    
    @staticmethod
    def get_location_details(latitude: float, longitude: float) -> Dict:
        """
        Get detailed location information from coordinates.
        """
        try:
            url = f"{OSMService.NOMINATIM_BASE_URL}/reverse"
            params = {
                'format': 'json',
                'lat': latitude,
                'lon': longitude,
                'zoom': 18,
                'addressdetails': 1,
                'extratags': 1
            }
            headers = {'User-Agent': 'Net-Fence-AI/1.0'}
            
            response = requests.get(url, params=params, headers=headers, timeout=5)
            response.raise_for_status()
            
            data = response.json()
            
            return {
                'name': data.get('name', 'Unknown'),
                'address': data.get('address', {}),
                'display_name': data.get('display_name', ''),
                'osm_id': data.get('osm_id'),
                'osm_type': data.get('osm_type'),
                'latitude': latitude,
                'longitude': longitude,
            }
            
        except Exception as e:
            logger.warning(f"Error getting location details for {latitude}, {longitude}: {e}")
            return {
                'name': 'Unknown Location',
                'latitude': latitude,
                'longitude': longitude,
            }
    
    @staticmethod
    def clear_cache():
        """Clear the geocoding cache"""
        OSMService.get_place_name.cache_clear()
