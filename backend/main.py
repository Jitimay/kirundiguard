from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import httpx
import os
import json
import logging
from dotenv import load_dotenv

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

load_dotenv()

app = FastAPI(title="KirundiGuard API", version="1.0.0")

# Add CORS middleware for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your Flutter app's origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ExplainRequest(BaseModel):
    text: str

class FollowUpRequest(BaseModel):
    query: str
    original_text: str
    document_type: str

def generate_local_explanation(text, smart_analysis):
    """Generate a local explanation when AI service fails"""
    doc_type = smart_analysis['document_type']
    
    # Generate basic explanations based on document type
    explanations = {
        'contract': {
            'summary': 'Iki ni cyemezo cy\'amasezerano. Gisaba ko abashyize umukono babahiriza ibyo biyemeje.',
            'sections': [
                {'title': 'Amasezerano', 'text': 'Iki cyemezo gishyiraho amasezerano hagati y\'abantu babiri cyangwa benshi.'},
                {'title': 'Inshingano', 'text': 'Buri muntu afite inshingano ze mu cyemezo.'}
            ],
            'checklist': [
                'Soma cyemezo cyose neza',
                'Menya inshingano zawe',
                'Baza ibibazo niba hari icyo utumva'
            ]
        },
        'law': {
            'summary': 'Iki ni cyemezo cy\'amategeko. Gishyiraho amategeko agomba gukurikizwa.',
            'sections': [
                {'title': 'Amategeko', 'text': 'Aya ni amategeko agomba gukurikizwa n\'abaturage bose.'},
                {'title': 'Ibihano', 'text': 'Hari ibihano ku batabahuza amategeko.'}
            ],
            'checklist': [
                'Menya amategeko mashya',
                'Koresha amategeko mu buzima bwawe',
                'Baza abunganira mu mategeko niba bikenewe'
            ]
        }
    }
    
    default_explanation = {
        'summary': 'Iki ni cyemezo cy\'ubwiyunge. Gisaba ko usomwe kandi ubyumve neza.',
        'sections': [
            {'title': 'Ibisobanuro', 'text': 'Iki cyemezo gishingiye ku mategeko y\'igihugu.'},
            {'title': 'Inshingano', 'text': 'Abaturage bagomba kubahiriza amategeko yose.'}
        ],
        'checklist': [
            'Soma cyangwa umve inyandiko yose',
            'Baza ibibazo niba hari icyo utumva',
            'Kubana n\'abunganira mu mategeko niba bikenewe'
        ]
    }
    
    explanation = explanations.get(doc_type, default_explanation)
    
    return {
        'summary_rn': explanation['summary'],
        'sections_rn': explanation['sections'],
        'checklist_rn': explanation['checklist'],
        'disclaimer_rn': 'Ibi ni inama gusa, si ubunganira mu mategeko. Saba inama z\'abunganira mu mategeko niba bikenewe.',
        'smart_analysis': smart_analysis
    }

def analyze_document_type(text):
    """Simple document type detection based on keywords"""
    text_lower = text.lower()
    
    # Document type keywords
    type_keywords = {
        'contract': ['contract', 'agreement', 'party', 'obligation', 'terms', 'conditions'],
        'law': ['article', 'section', 'law', 'regulation', 'statute', 'shall', 'must'],
        'idForm': ['identity', 'passport', 'license', 'registration', 'application', 'form'],
        'governmentNotice': ['notice', 'announcement', 'government', 'ministry', 'public'],
        'courtDocument': ['court', 'judge', 'plaintiff', 'defendant', 'case', 'hearing'],
        'businessLicense': ['license', 'permit', 'business', 'trade', 'commerce', 'tax'],
        'propertyDocument': ['property', 'land', 'title', 'deed', 'ownership', 'mortgage']
    }
    
    best_match = 'unknown'
    highest_score = 0
    
    for doc_type, keywords in type_keywords.items():
        matches = sum(1 for keyword in keywords if keyword in text_lower)
        score = matches / len(keywords)
        
        if score > highest_score:
            highest_score = score
            best_match = doc_type
    
    # Generate suggested questions based on document type
    suggested_questions = {
        'contract': [
            'What are my main obligations?',
            'When do I need to make payments?',
            'How can I terminate this agreement?'
        ],
        'law': [
            'How does this law affect me?',
            'What are the penalties for violation?',
            'When does this law take effect?'
        ],
        'idForm': [
            'What documents do I need to provide?',
            'How long does processing take?',
            'What are the fees involved?'
        ]
    }
    
    return {
        'document_type': best_match,
        'confidence': highest_score,
        'suggested_questions': suggested_questions.get(best_match, [
            'What does this document mean for me?',
            'What actions do I need to take?',
            'Are there any important deadlines?'
        ])
    }

@app.get("/")
def read_root():
    return {"message": "KirundiGuard API is running", "status": "healthy"}

@app.get("/health")
def health_check():
    api_key = os.getenv("OPENROUTER_API_KEY")
    return {
        "status": "healthy",
        "api_key_configured": bool(api_key and api_key.startswith("sk-")),
        "timestamp": "2024-01-01"
    }

@app.post("/explain")
async def explain_text(request: ExplainRequest):
    if not request.text or not request.text.strip():
        raise HTTPException(status_code=400, detail="Text cannot be empty")
    
    api_key = os.getenv("OPENROUTER_API_KEY")
    if not api_key:
        logger.error("OPENROUTER_API_KEY not set")
        raise HTTPException(status_code=500, detail="API key not configured")

    logger.info(f"Processing text of length: {len(request.text)}")
    
    # Perform smart analysis
    smart_analysis = analyze_document_type(request.text)
    logger.info(f"Document type detected: {smart_analysis['document_type']} (confidence: {smart_analysis['confidence']:.2f})")

    prompt = f"""You are KirundiGuard, an AI legal assistant for Burundian citizens.
Your purpose is to explain complex legal documents (contracts, government papers, etc.) in simple, clear Kirundi.

**User's Document Text:**
{request.text}

**Your Task:**
1. **Analyze the text:** Identify the key clauses, obligations, and rights.
2. **Explain in Simple Kirundi:** Provide a summary and section-by-section explanation of the document in plain Kirundi.
3. **Create a Checklist:** Give the user a simple checklist of actions they should consider.
4. **Add a Disclaimer:** Remind the user that you are an AI assistant, not a human lawyer.

**Response Format:**
You MUST respond with ONLY a valid JSON object. No explanations, no markdown, no extra text.

Use this EXACT structure:
{{
  "summary_rn": "Summary in Kirundi here",
  "sections_rn": [
    {{"title": "Section title in Kirundi", "text": "Section explanation in Kirundi"}}
  ],
  "checklist_rn": [
    "Action item 1 in Kirundi",
    "Action item 2 in Kirundi"
  ],
  "disclaimer_rn": "Disclaimer in Kirundi",
  "smart_analysis": {{
    "document_type": "contract",
    "confidence": 0.8,
    "key_terms": ["term1", "term2"],
    "relevant_sections": ["section1"],
    "suggested_questions": ["question1"],
    "quick_facts": {{"fact": "value"}}
  }}
}}

CRITICAL: Return ONLY valid JSON. No markdown blocks, no explanations, just the JSON object.
"""

    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                "https://openrouter.ai/api/v1/chat/completions",
                headers={
                    "Authorization": f"Bearer {api_key}",
                    "Content-Type": "application/json"
                },
                json={
                    "model": "openai/gpt-3.5-turbo",
                    "messages": [
                        {"role": "user", "content": prompt}
                    ],
                    "temperature": 0.3,
                    "max_tokens": 1500,
                    "frequency_penalty": 1.0,
                    "presence_penalty": 0.5
                }
            )

        if response.status_code == 200:
            openrouter_response = response.json()
            explanation_text = openrouter_response['choices'][0]['message']['content']
            
            # Clean the response to ensure it's valid JSON
            explanation_text = explanation_text.strip()
            
            # Remove markdown code blocks if present
            if explanation_text.startswith('```json'):
                explanation_text = explanation_text[7:]
            if explanation_text.startswith('```'):
                explanation_text = explanation_text[3:]
            if explanation_text.endswith('```'):
                explanation_text = explanation_text[:-3]
            explanation_text = explanation_text.strip()
            
            # Log the raw response for debugging
            logger.info(f"Raw AI response (first 500 chars): {explanation_text[:500]}")
            
            try:
                explanation_json = json.loads(explanation_text)
                logger.info("Successfully generated explanation")
                return explanation_json
            except json.JSONDecodeError as e:
                logger.error(f"Invalid JSON from AI: {e}")
                logger.error(f"Problematic text: {explanation_text}")
                
                # Try to fix common JSON issues
                try:
                    import re
                    fixed_text = explanation_text
                    
                    # Fix unquoted property names
                    fixed_text = re.sub(r'(\w+):', r'"\1":', fixed_text)
                    # Fix already quoted properties (avoid double quotes)
                    fixed_text = re.sub(r'""(\w+)"":', r'"\1":', fixed_text)
                    # Remove trailing commas
                    fixed_text = re.sub(r',(\s*[}\]])', r'\1', fixed_text)
                    
                    explanation_json = json.loads(fixed_text)
                    logger.info("Successfully parsed JSON after fixing")
                    return explanation_json
                except Exception as fix_error:
                    logger.error(f"JSON fix failed: {fix_error}")
                    # Return fallback response
                    # If all else fails, return a structured fallback response
                    logger.warning("Using fallback response due to JSON parsing failure")
                    return {
                        "summary_rn": "Inyandiko yawe yashyizweho mu gahunda y'ubwiyunge. Ariko hari ikibazo mu gusobanura amakuru.",
                        "sections_rn": [
                            {"title": "Ikibazo cy'ikoranabuhanga", "text": "Hari ikibazo mu gusoma inyandiko yawe. Gerageza kwongera ugerageze."}
                        ],
                        "checklist_rn": [
                            "Gerageza kwongera ushyire inyandiko",
                            "Reba niba inyandiko ifite amakuru ahagije"
                        ],
                        "disclaimer_rn": "Ibi ni inama gusa, si ubunganira mu mategeko.",
                        "smart_analysis": smart_analysis
                    }
        else:
            logger.error(f"OpenRouter API error: {response.status_code} - {response.text}")
            raise HTTPException(status_code=500, detail="AI service unavailable")
            
    except httpx.TimeoutException:
        logger.error("Request to OpenRouter timed out")
        raise HTTPException(status_code=504, detail="AI service timeout")
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        # Fallback to local processing if AI fails
        logger.warning("AI service failed, using local fallback")
        return generate_local_explanation(request.text, smart_analysis)

@app.post("/follow-up")
async def follow_up_query(request: FollowUpRequest):
    if not request.query or not request.query.strip():
        raise HTTPException(status_code=400, detail="Query cannot be empty")
    
    if not request.original_text or not request.original_text.strip():
        raise HTTPException(status_code=400, detail="Original text cannot be empty")

    logger.info(f"Processing follow-up query: {request.query}")

    # Simple rule-based responses for common queries
    query_lower = request.query.lower()
    text_lower = request.original_text.lower()
    
    try:
        if 'article' in query_lower and 'mean' in query_lower:
            # Extract article number and find explanation
            import re
            article_match = re.search(r'article\s+(\d+)', query_lower)
            if article_match:
                article_num = article_match.group(1)
                lines = request.original_text.split('\n')
                for i, line in enumerate(lines):
                    if f'article {article_num}' in line.lower():
                        explanation = ' '.join(lines[i:i+3]).strip()
                        return {"response": f"Article {article_num} states: {explanation}"}
            
            return {"response": "I couldn't find the specific article you mentioned. Please check the document for the exact article number."}
        
        elif 'obligation' in query_lower or 'responsibility' in query_lower:
            obligations = []
            lines = request.original_text.split('\n')
            for line in lines:
                line_lower = line.lower()
                if any(word in line_lower for word in ['shall', 'must', 'obligation', 'responsible', 'duty', 'required']):
                    obligations.append(line.strip())
            
            if obligations:
                response_text = "**Your main obligations include:**\n\n"
                for i, obligation in enumerate(obligations[:3], 1):
                    response_text += f"{i}. {obligation}\n"
                response_text += "\n💡 **Tip:** Make sure to understand each obligation fully and note any deadlines or conditions mentioned."
                return {"response": response_text}
            else:
                return {"response": "I couldn't find specific obligations clearly stated in this document. However, most legal documents contain implicit responsibilities. I recommend reviewing the document carefully for terms like 'shall', 'must', 'required', or 'responsible'."}
        
        elif 'penalty' in query_lower or 'fine' in query_lower or 'breach' in query_lower:
            penalties = []
            lines = request.original_text.split('\n')
            for line in lines:
                line_lower = line.lower()
                if any(word in line_lower for word in ['penalty', 'fine', 'punishment', 'breach', 'violation', 'default', 'damages']):
                    penalties.append(line.strip())
            
            if penalties:
                response_text = "**Penalties and consequences mentioned:**\n\n"
                for i, penalty in enumerate(penalties[:3], 1):
                    response_text += f"{i}. {penalty}\n"
                response_text += "\n⚠️ **Important:** These are serious consequences. Consider seeking legal advice if you're unsure about compliance."
                return {"response": response_text}
            else:
                return {"response": "I couldn't find specific penalties mentioned in this document. However, most legal agreements have consequences for non-compliance. Look for sections about 'breach', 'default', 'violation', or 'damages'."}
        
        elif 'deadline' in query_lower or 'when' in query_lower:
            deadlines = []
            lines = request.original_text.split('\n')
            for line in lines:
                line_lower = line.lower()
                if any(word in line_lower for word in ['deadline', 'due', 'before', 'within']):
                    deadlines.append(line.strip())
            
            if deadlines:
                return {"response": f"Important deadlines: {'; '.join(deadlines[:2])}"}
            else:
                return {"response": "No specific deadlines were clearly mentioned in this document."}
        
        elif 'fee' in query_lower or 'cost' in query_lower:
            fees = []
            lines = request.original_text.split('\n')
            for line in lines:
                line_lower = line.lower()
                if any(word in line_lower for word in ['fee', 'cost', 'payment', 'amount']):
                    fees.append(line.strip())
            
            if fees:
                return {"response": f"Fees and costs: {'; '.join(fees[:2])}"}
            else:
                return {"response": "No specific fees or costs were mentioned in this document."}
        
        else:
            # Default response with more helpful content
            doc_type_display = {
                'contract': 'Contract',
                'law': 'Legal Document',
                'idForm': 'ID/Form',
                'governmentNotice': 'Government Notice',
                'courtDocument': 'Court Document',
                'businessLicense': 'Business License',
                'propertyDocument': 'Property Document'
            }.get(request.document_type, 'Document')
            
            # Provide a more detailed response
            response_text = f"""I understand you're asking about "{request.query}".

Based on the document type ({doc_type_display}), here are some general insights:

• This appears to be a {doc_type_display.lower()} that may contain important legal or procedural information
• I recommend carefully reviewing the specific sections that relate to your question
• If you need more specific information, try asking about particular clauses, deadlines, or requirements mentioned in the document

Would you like to ask about a specific section or aspect of this document?"""
            
            return {"response": response_text}
    
    except Exception as e:
        logger.error(f"Follow-up query error: {e}")
        return {"response": "I'm sorry, I couldn't process your question at the moment. Please try rephrasing it or ask about specific sections of the document."}