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
  "disclaimer_rn": "<Disclaimer in Kirundi>"
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