#!/usr/bin/env python3
import requests
import json

def test_connection():
    # Test the health endpoint first
    try:
        print("Testing connection to backend...")
        response = requests.get("http://10.0.2.2:8000/", timeout=10)
        print(f"✅ Health check: {response.status_code} - {response.json()}")
        
        # Test the explain endpoint
        test_data = {"text": "This is a test contract"}
        response = requests.post("http://10.0.2.2:8000/explain", json=test_data, timeout=60)
        print(f"✅ Explain endpoint: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"Got response: {result.get('summary_rn', 'No summary')[:50]}...")
        else:
            print(f"Error: {response.text}")
            
    except requests.exceptions.ConnectionError as e:
        print(f"❌ Connection error: {e}")
    except requests.exceptions.Timeout as e:
        print(f"❌ Timeout error: {e}")
    except Exception as e:
        print(f"❌ Other error: {e}")

if __name__ == "__main__":
    test_connection()