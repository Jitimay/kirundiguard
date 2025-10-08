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
Your response MUST be a valid JSON object with this exact structure:
{{
  "summary_rn": "<Summary in Kirundi>",
  "sections_rn": [
    {{"title": "<Section 1 Title in Kirundi>", "text": "<Section 1 Explanation in Kirundi>"}},
    {{"title": "<Section 2 Title in Kirundi>", "text": "<Section 2 Explanation in Kirundi>"}}
  ],
  "checklist_rn": [
    "<Action item 1 in Kirundi>",
    "<Action item 2 in Kirundi>"
  ],
  "disclaimer_rn": "<Disclaimer in Kirundi>",
  "smart_analysis": {{
    "document_type": "<detected document type>",
    "confidence": <confidence score 0-1>,
    "key_terms": ["<key term 1>", "<key term 2>"],
    "relevant_sections": ["<relevant section 1>", "<relevant section 2>"],
    "suggested_questions": ["<question 1>", "<question 2>"],
    "quick_facts": {{"<fact name>": "<fact value>"}}
  }}
}}

IMPORTANT: Return ONLY the JSON object, no other text before or after it.
"""

    try:
        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(
                "https://openrouter.ai/api/v1/chat/completions",
                headers={
                    "Authorization": f"Bearer {api_key}",
                    "Content-Type": "application/json"
                },
                json={
                    "model": "google/gemini-2.0-flash-exp:free",
                    "messages": [
                        {"role": "user", "content": prompt}
                    ],
                    "temperature": 0.7,
                    "max_tokens": 2000
                }
            )

        if response.status_code == 200:
            openrouter_response = response.json()
            explanation_text = openrouter_response['choices'][0]['message']['content']
            
            # Clean the response to ensure it's valid JSON
            explanation_text = explanation_text.strip()
            if explanation_text.startswith('```json'):
                explanation_text = explanation_text[7:]
            if explanation_text.endswith('```'):
                explanation_text = explanation_text[:-3]
            explanation_text = explanation_text.strip()
            
            try:
                explanation_json = json.loads(explanation_text)
                logger.info("Successfully generated explanation")
                return explanation_json
            except json.JSONDecodeError as e:
                logger.error(f"Invalid JSON from AI: {e}")
                raise HTTPException(status_code=500, detail="AI returned invalid response format")
        else:
            logger.error(f"OpenRouter API error: {response.status_code} - {response.text}")
            raise HTTPException(status_code=500, detail="AI service unavailable")
            
    except httpx.TimeoutException:
        logger.error("Request to OpenRouter timed out")
        raise HTTPException(status_code=504, detail="AI service timeout")
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

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
                if any(word in line_lower for word in ['shall', 'must', 'obligation', 'responsible']):
                    obligations.append(line.strip())
            
            if obligations:
                return {"response": f"Your main obligations include: {'; '.join(obligations[:3])}"}
            else:
                return {"response": "No specific obligations were clearly identified in this document."}
        
        elif 'penalty' in query_lower or 'fine' in query_lower:
            penalties = []
            lines = request.original_text.split('\n')
            for line in lines:
                line_lower = line.lower()
                if any(word in line_lower for word in ['penalty', 'fine', 'punishment']):
                    penalties.append(line.strip())
            
            if penalties:
                return {"response": f"Penalties mentioned: {'; '.join(penalties[:2])}"}
            else:
                return {"response": "No specific penalties were found in this document."}
        
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
            # Default response
            doc_type_display = {
                'contract': 'Contract',
                'law': 'Legal Document',
                'idForm': 'ID/Form',
                'governmentNotice': 'Government Notice',
                'courtDocument': 'Court Document',
                'businessLicense': 'Business License',
                'propertyDocument': 'Property Document'
            }.get(request.document_type, 'Document')
            
            return {"response": f"I understand you're asking about \"{request.query}\". Based on the document type ({doc_type_display}), I recommend reviewing the relevant sections I've highlighted above."}
    
    except Exception as e:
        logger.error(f"Follow-up query error: {e}")
        return {"response": "I'm sorry, I couldn't process your question at the moment. Please try rephrasing it or ask about specific sections of the document."}