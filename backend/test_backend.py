#!/usr/bin/env python3
"""
Test script for KirundiGuard backend
"""

import requests
import json

def test_backend():
    url = "http://localhost:8000/explain"
    
    # Test with sample legal text
    test_text = """
    CONTRAT DE TRAVAIL
    
    Entre l'employeur ABC Company et l'employé Jean Doe.
    Salaire: 500,000 BIF par mois
    Durée: Contrat à durée indéterminée
    Période d'essai: 3 mois
    Congés: 21 jours par an
    """
    
    data = {"text": test_text}
    
    try:
        print("Testing backend...")
        response = requests.post(url, json=data, timeout=60)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Backend working!")
            print(f"Summary: {result.get('summary_rn', 'N/A')}")
            print(f"Sections: {len(result.get('sections_rn', []))}")
            print(f"Checklist items: {len(result.get('checklist_rn', []))}")
            return True
        else:
            print(f"❌ Error: {response.status_code}")
            print(response.text)
            return False
            
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to backend. Is it running on localhost:8000?")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    test_backend()