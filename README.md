# AI LLM GALLERY (iOS)

A high-performance iOS application demonstrating on-device LLM capabilities using Google MediaPipe GenAI.

## Features
- **On-Device Chat**: Fast, private, and secure AI conversations.
- **AI Quizzes**: Generate and play educational quizzes on any topic.
- **Story Generation**: Creative writing assisted by on-device intelligence.
- **Multimodal Support**: Future-ready architecture for vision and audio tasks.

## Setup Instructions

### 1. Frameworks
The binary frameworks for MediaPipe are excluded from this repository due to GitHub's file size limits (over 100MB). To run the project:
1. Download `MediaPipeTasksGenAI.xcframework` and `MediaPipeTasksGenAIC.xcframework` from the official Google MediaPipe releases.
2. Place them in the `Frameworks/` directory in the project root.
3. Ensure they are linked in the Xcode project settings under "Frameworks, Libraries, and Embedded Content" with "Embed & Sign".

### 2. Models
The application requires `.task` or `.bin` models (e.g., Gemma, Phi-2) to be downloaded within the app's Settings or manually placed in the App's Documents folder under `/models`.

## Project Structure
- `AI/`: Core inference engine and manager logic.
- `ViewModels/`: UI business logic and model orchestration.
- `Views/`: SwiftUI components and screens.
- `Theme/`: Design system and styling tokens.

## License
MIT
