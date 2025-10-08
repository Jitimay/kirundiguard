#!/usr/bin/env python3
"""
Test script for Smart Assistant functionality
"""

import requests
import json

# Test document samples
test_documents = {
    "contract": """
    EMPLOYMENT CONTRACT
    
    This agreement is between ABC Company and John Doe.
    
    Article 1: The employee shall work 40 hours per week.
    Article 2: The monthly salary is $2000, payable on the 30th of each month.
    Article 3: The employee must give 30 days notice for termination.
    Article 4: Breach of contract results in immediate termination and penalty of $500.
    
    Both parties agree to these terms and conditions.
    """,
    
    "law": """
    TRAFFIC REGULATION LAW
    
    Article 5: All drivers must possess a valid driving license.
    Article 6: Speed limit in urban areas is 50 km/h.
    Article 7: Violation of speed limits results in a fine of $100.
    Article 8: Driving under influence is prohibited and punishable by imprisonment.
    
    This law takes effect on January 1, 2024.
    """,
    
    "government_notice": """
    GOVERNMENT NOTICE - TAX FILING
    
    All citizens are required to file their annual tax returns.
    
    Deadline: March 31, 2024
    Required documents: Income statements, receipts, bank statements
    Filing fee: $25
    
    Failure to file by the deadline results in a penalty of $200.
    Contact the Revenue Authority for assistance.
    """
}

def test_explanation_api(document_type, text):
    """Test the main explanation API"""
    print(f"\n🧪 Testing {document_type.upper()} document...")
    
    try:
        response = requests.post(
            "http://localhost:8000/explain",
            json={"text": text},
            timeout=30
        )
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ API Success!")
            print(f"📄 Document Type: {data.get('smart_analysis', {}).get('document_type', 'unknown')}")
            print(f"🎯 Confidence: {data.get('smart_analysis', {}).get('confidence', 0):.2f}")
            print(f"💡 Suggested Questions: {len(data.get('smart_analysis', {}).get('suggested_questions', []))}")
            return data
        else:
            print(f"❌ API Error: {response.status_code}")
            print(f"Response: {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ Request failed: {e}")
        return None

def test_follow_up_api(query, original_text, document_type):
    """Test the follow-up query API"""
    print(f"\n❓ Testing follow-up query: '{query}'")
    
    try:
        response = requests.post(
            "http://localhost:8000/follow-up",
            json={
                "query": query,
                "original_text": original_text,
                "document_type": document_type
            },
            timeout=15
        )
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Follow-up Success!")
            print(f"💬 Response: {data.get('response', 'No response')}")
            return data
        else:
            print(f"❌ Follow-up Error: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"❌ Follow-up failed: {e}")
        return None

def main():
    print("🚀 Smart Assistant API Test Suite")
    print("=" * 50)
    
    # Test each document type
    for doc_type, text in test_documents.items():
        result = test_explanation_api(doc_type, text)
        
        if result and 'smart_analysis' in result:
            detected_type = result['smart_analysis'].get('document_type', 'unknown')
            
            # Test follow-up queries based on document type
            if doc_type == "contract":
                test_follow_up_api("What are my main obligations?", text, detected_type)
                test_follow_up_api("What happens if I breach this contract?", text, detected_type)
                
            elif doc_type == "law":
                test_follow_up_api("What does Article 5 mean for me?", text, detected_type)
                test_follow_up_api("What are the penalties for violation?", text, detected_type)
                
            elif doc_type == "government_notice":
                test_follow_up_api("What is the deadline?", text, detected_type)
                test_follow_up_api("What are the fees involved?", text, detected_type)
    
    print("\n🎉 Test suite completed!")

if __name__ == "__main__":
    main()