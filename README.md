# AI Companion for Visually Impaired People

### Intelligent Navigation and Assistance System

An AI-powered accessibility assistant designed primarily for visually impaired users. The system provides voice-first interaction and combines speech processing, computer vision, OCR, object detection, currency recognition, navigation, translation, and conversational AI into a single assistant.

The system follows the principle:

> **Assist, Don't Overwhelm.**

It provides relevant assistance based on the user's request and context rather than continuously reporting every detected object.

## Project Goal

The goal of this project is to develop an accessible AI Companion that helps visually impaired users:

- Interact with the system through voice
- Read and understand printed text
- Recognize currency
- Identify relevant objects and surroundings
- Ask questions using conversational AI
- Translate information into preferred languages
- Get navigation and location assistance
- Access emergency-related support
- Use personalized preferences through a single integrated system

  ## Key Features

- 🎙️ Voice-first interaction
- 🗣️ Speech-to-Text using Whisper
- 🔊 Text-to-Speech
- 🌐 Multilingual support
- 📖 OCR and text reading
- 📷 Automatic image-quality checking before OCR
- 💰 Currency recognition
- 👁️ Object detection using YOLOv8
- 🌍 Basic scene understanding
- 🤖 Conversational AI using a local LLM
- 🗺️ GPS and navigation assistance
- 🔄 Language translation
- 🚨 Emergency contact and assistance features
- 👤 User authentication and personalization
- 💾 MySQL-based user data management
- ⚡ Hybrid online/offline architecture

  ## How It Works

User
  ↓
Voice / Text / Camera
  ↓
Flutter Frontend
  ↓
Flask Backend
  ↓
Request Processing
  ↓
AI / Computer Vision / Location Services
  ↓
Result
  ↓
Text + Speech Response
  ↓
User


## Technology Stack

| Component | Technology |
|---|---|
| Frontend | Flutter |
| Backend | Python, Flask |
| Database | MySQL |
| Speech-to-Text | Whisper / faster-whisper |
| Text-to-Speech | TTS Engine |
| OCR | EasyOCR / Tesseract |
| Image Processing | OpenCV |
| Object Detection | YOLOv8 |
| Conversational AI | Local LLM / Ollama |
| Translation | Google Language Translation |
| Navigation | Maps / Navigation API |
| Location | GPS / Location Services |
| Version Control | Git & GitHub |


## Project Scope

### Current Scope

- Voice-based accessibility
- Speech recognition and audio responses
- OCR with automatic image-quality assessment
- Currency recognition
- Object detection
- Basic scene understanding
- Conversational AI
- Multilingual interaction
- Translation
- GPS/location support
- Navigation assistance
- User authentication and preferences
- Emergency-related functionality
- Hybrid online/offline operation

### Future Scope

- Smart-glasses integration
- Depth-based distance estimation
- Improved obstacle and path assistance
- Activity detection
- Free-space detection
- Advanced path planning
- Low-power wearable AI
- Battery monitoring
- Improved offline AI capabilities

## System Architecture
->
                 USER
                   │
        ┌──────────┴──────────┐
        │                     │
     Voice                  Camera
        │                     │
        └──────────┬──────────┘
                   ↓
             Flutter App
                   ↓
              Flask API
                   ↓
          Request Processing
                   ↓
      ┌────────────┼────────────┐
      ↓            ↓            ↓
   Whisper      Computer       AI
                Vision         LLM
      │            │            │
      │       ┌────┼────┐       │
      │       ↓    ↓    ↓       │
      │      OCR YOLO Currency  │
      │                         │
      └───────────┬─────────────┘
                  ↓
          MySQL / External APIs
                  ↓
             Result / TTS
                  ↓
                 USER


                 
## Database

The project uses MySQL for persistent user-related data.

### Main Entities

- USER
- USER_PREFERENCES
- LOCATION
- EMERGENCY_CONTACT
- SAVED_INFORMATION

### Relationships

- User → User Preferences: 1:1
- User → Location: 1:M
- User → Emergency Contact: 1:M
- User → Saved Information: 1:M

  ## Online & Offline Support

The system follows a hybrid architecture.

### Local / Offline Capabilities

Depending on deployment and installed models:

- OCR
- Image-quality assessment
- Object detection
- Currency recognition
- Basic scene understanding
- Local conversational AI
- Local speech processing
- Text-to-Speech

### Online Services

Internet may be required for:

- Google Language Translation
- Online Maps and Navigation
- Real-time traffic/information
- External APIs
- Cloud-based services
