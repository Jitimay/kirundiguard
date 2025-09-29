# KirundiGuard - Complete Setup Guide

## 🚀 Quick Start

### 1. Start the Backend
```bash
cd backend
python run.py
```
You should see: `INFO: Uvicorn running on http://0.0.0.0:8000`

### 2. Test the Backend (Optional)
```bash
cd backend
python test_backend.py
```
You should see: `✅ Backend working!`

### 3. Start Flutter App
```bash
flutter run
```

## 🔍 Testing the Complete Flow

1. **Scan a Document**: Tap "Scan Document" or "Import PDF"
2. **Wait for OCR**: Text should appear in the app
3. **Click "Explain Document"**: This triggers the AI call
4. **Watch the Console**: You'll see debug logs like:
   ```
   🔄 ExplainBloc: Starting explanation generation...
   📡 AiService: Sending request to backend...
   ✅ AiService: Response data received, parsing...
   🎉 ExplainBloc: Emitted success state
   ```

## 🐛 Troubleshooting

### Backend Issues:
- **"Connection timeout"**: Backend not running → Start with `python run.py`
- **"API key not configured"**: Check your `.env` file has `OPENROUTER_API_KEY`
- **"AI service unavailable"**: OpenRouter API issue → Check your API key

### Flutter Issues:
- **No response**: Check Flutter console for error logs
- **Network error**: Make sure backend is on `localhost:8000`

## 📱 Expected Flow:
1. User scans document → OCR extracts text
2. User clicks "Explain Document" → ExplainBloc calls AiService
3. AiService sends HTTP request → Your FastAPI backend
4. Backend calls OpenRouter → Gemini processes the text
5. Gemini returns Kirundi explanation → Backend returns JSON
6. Flutter displays the explanation → User sees result

## 🔧 Debug Mode:
The app now has detailed logging. Watch the console to see exactly where the process stops if there are issues.