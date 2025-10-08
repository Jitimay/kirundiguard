# Getting Started with KirundiGuard

This guide will help you set up and run the KirundiGuard app locally.

## Prerequisites

Make sure you have:
- Python 3.8+ installed
- Flutter SDK installed
- An Android device or emulator

## Running the Application

### Step 1: Backend Setup

First, you need to start the Python backend server:

```bash
cd backend
pip install -r requirements.txt
python run.py
```

The server should start on port 8000. You'll see a message like:
```
INFO: Uvicorn running on http://0.0.0.0:8000
```

### Step 2: API Configuration (Optional)

For full AI functionality, create a `.env` file in the backend directory:

```bash
echo "OPENROUTER_API_KEY=your_api_key_here" > .env
```

Note: The app works without an API key using fallback responses.

### Step 3: Flutter App

In a new terminal, start the Flutter app:

```bash
flutter pub get
flutter run
```

## Using the App

1. Open the app and tap "Scan Document"
2. Take a photo of any text document
3. Wait for the text extraction to complete
4. Tap "Explain Document" to get the analysis
5. Use the Smart Assistant to ask follow-up questions

## Common Issues

**Backend won't start**: Make sure you installed the requirements with `pip install -r requirements.txt`

**Flutter can't connect**: Check that the backend is running and the IP address in `lib/core/services/ai_service.dart` matches your machine's IP.

**OCR not working**: Ensure camera permissions are granted on your device.

## Architecture Notes

The app uses a Flutter frontend with a FastAPI backend. Document processing happens through Google ML Kit for OCR, and explanations are generated using the OpenRouter API with Gemini models. The Smart Assistant provides contextual document analysis and interactive Q&A functionality.