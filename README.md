# IkirundiGuard

A Flutter prototype app that helps Burundians understand government/legal documents by scanning, explaining, and reading them aloud in Kirundi.

## Features

### Core Features (Prototype)
- **Document Scanning**: Import photos or PDF documents using camera or file picker
- **OCR Processing**: Extract text using Google ML Kit Text Recognition (on-device)
- **AI Explanation**: Generate explanations via MethodChannel to Google AI Edge SDK (stub implementation)
- **Text-to-Speech**: Read explanations aloud in Kirundi (fallback to Swahili)
- **History**: Store and view last 5 explanations locally using Hive
- **Server Fallback**: Improve accuracy with mock server API calls

### UI/UX
- Material 3 design with green theme
- Home screen with scan/import buttons and history
- Result screen with expandable sections, checklist, and disclaimer
- TTS controls for audio playback

## Tech Stack

- **Flutter 3.x** with null safety
- **State Management**: BLoC pattern with flutter_bloc
- **OCR**: google_mlkit_text_recognition
- **TTS**: flutter_tts
- **Storage**: Hive for local data persistence
- **HTTP**: Dio for API calls
- **File Handling**: image_picker, file_picker

## Project Structure

```
lib/
├── core/
│   ├── models/          # Hive data models
│   ├── services/        # AI, TTS, Storage services
│   └── theme/           # App theming
├── features/
│   ├── ocr/            # Document scanning & OCR
│   ├── explain/        # AI explanation generation
│   ├── history/        # Local storage & history
│   └── home/           # Main home screen
└── main.dart           # App entry point
```

## Getting Started

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Generate Hive adapters**:
   ```bash
   flutter packages pub run build_runner build
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

## Native Integration

### Android Method Channel
The app includes a Kotlin stub in `android/app/src/main/kotlin/com/example/kirundiguard/MainActivity.kt` that provides dummy AI explanations. Replace the `generateExplanation` method with actual Google AI Edge SDK integration.

### Permissions
Required Android permissions are configured in `AndroidManifest.xml`:
- Camera access
- Storage read/write
- Internet access

## API Integration

The app includes a mock server endpoint at `/explain` for improved accuracy. Update the base URL in `AiService` to point to your actual server.

## Language Support

- Primary: Kirundi (rn)
- Fallback: Swahili (sw-KE)
- UI: English

## Development Notes

- Uses minimal code approach for prototype
- Hive for efficient local storage (last 5 items)
- BLoC pattern for clean state management
- Material 3 design system
- Organized feature-based architecture
# kirundiguard
