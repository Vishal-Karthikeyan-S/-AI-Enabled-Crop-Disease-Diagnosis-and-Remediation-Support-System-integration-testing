# Sprint-1 Developer Documentation

## AI-Enabled Crop Disease Diagnosis System
**Documentation Version: 1.0 | Last Updated: Sprint-1 Completion**

---

## 1. Sprint-1 Overview

### Goals
Implement an offline-first crop disease diagnosis system with store-and-forward synchronization for agricultural users with intermittent network connectivity.

### Scope
Mobile and web application providing complete disease diagnosis workflow without requiring continuous internet connectivity.

### Implemented Capabilities
- User authentication with local session persistence
- Camera-based image capture and gallery selection
- Local SQLite storage with submission queuing
- Background synchronization service with retry logic
- Simulated ML processing with 3-second inference delay
- Multi-language support (English, Hindi, Tamil, Telugu)
- Text-to-speech accessibility features
- Client-driven polling-based status tracking and history management
- Settings management for theme, font, and TTS preferences

---

## 2. System Architecture Summary

### Client Layer
Flutter cross-platform application implementing Provider pattern for reactive state management. Local SQLite database serves as primary data store with HTTP client for API communication.

### Backend Layer
FastAPI async web framework with SQLAlchemy ORM. Implements RESTful endpoints for file upload, status polling, and result retrieval. Background tasks for ML processing simulation using FastAPI BackgroundTasks.

### Data Layer
SQLite for client-side persistence and queue management. PostgreSQL for server-side data storage and audit trail.

### External Systems
None required for Sprint-1; all functionality operates within local application environment.

### Offline-First Strategy
Local SQLite database serves as primary data store. Background sync service manages queue-based data synchronization when connectivity is restored.

### High-Level Architecture Diagram
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   FastAPI       │    │   PostgreSQL    │
│                 │    │   Backend       │    │   Database      │
│ ┌─────────────┐ │    │                 │    │ ┌─────────────┐ │
│ │ SQLite DB   │ │    │ │ Media Table │ │    │ │ Media Table │ │
│ │ (Local)     │ │    │ └─────────────┘ │    │ └─────────────┘ │
│ └─────────────┘ │    │ ┌─────────────┐ │    │                 │
│ │ Sync Service│◄├────┤ │ ML Task     │ │    │                 │
│ └─────────────┘ │    │ └─────────────┘ │    │                 │
│ │ HTTP Client │◄├────┤ │ File System │ │    │                 │
│ └─────────────┘ │    │ └─────────────┘ │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## 3. Component Architecture

### Frontend

#### UI Screens
- **SplashScreen**: App initialization and branding
- **LoginScreen**: User authentication interface with credential validation
- **RegistrationScreen**: New user account creation
- **HomeScreen**: Main navigation hub
- **CameraScreen**: Device camera integration and gallery selection
- **PreviewScreen**: Image review and confirmation
- **ResultsScreen**: Diagnosis results with confidence scores
- **HistoryScreen**: Chronological submission history
- **SettingsScreen**: App configuration and preferences
- **TreatmentScreen**: Treatment recommendations display

#### Providers
- **ConnectivityProvider**: Network status monitoring and state broadcasting
- **LanguageProvider**: Localization management
- **ThemeProvider**: UI theme management
- **FontSizeProvider**: Text size accessibility controls
- **SubmissionProvider**: Upload status and progress tracking

#### Services
- **AuthService**: User authentication and session persistence
- **StorageService**: Local SQLite operations
- **SyncService**: Background synchronization with retry logic
- **ConnectivityService**: Network detection
- **TTSService**: Text-to-speech playback
- **SpeechService**: Voice command recognition
- **PreferencesService**: User settings persistence

#### State Management
Provider pattern with ChangeNotifier for reactive UI updates. Session data and user preferences persisted with SharedPreferences.

### Backend

#### Routers
- **UploadRouter**: `/api/upload-media` - File upload with deduplication
- **PredictionRouter**: `/api/prediction/{media_id}` - Result retrieval
- **StatusRouter**: `/api/media-status/{media_id}` - Processing status
- **HistoryRouter**: `/api/history` - User submission history

#### Services
- **MLTask**: Simulated machine learning processing with deterministic 3-second delay
- **DatabaseService**: SQLAlchemy session management and connection pooling
- **FileService**: Local file storage, retrieval, cleanup

#### ML Simulation Task
Updates media status: UPLOADED → PROCESSING → COMPLETED. Assigns mock diagnosis results with confidence score.

#### Database Models
- **Media**: Primary entity for submission tracking
- **Base**: SQLAlchemy declarative base for ORM mapping

---

## 4. Data Flow

### Authentication Flow
1. User enters credentials in LoginScreen
2. AuthService validates against local SQLite
3. Session persisted using SharedPreferences
4. User state updated via Provider pattern
5. Navigation redirected to HomeScreen

### Image Capture Flow
1. CameraScreen launches device camera
2. Image captured and saved locally
3. PreviewScreen displays image for confirmation
4. User confirms submission with metadata

### Offline Submission Flow
1. Submission saved to SQLite with PENDING status
2. File stored locally with UUID filename
3. UI shows "Saved (not uploaded)"
4. Added to sync queue with retry count

### Sync Workflow
1. ConnectivityService detects network restoration
2. SyncService processes pending queue
3. HTTP POST requests sent to backend
4. Local status updated based on server response
5. Failed submissions retried with exponential backoff

### Upload Pipeline
1. Multipart form data: file, media_id, user_id
2. Server validates file format and size
3. Unique media_id generated for deduplication
4. File stored in /uploads
5. ML task triggered asynchronously

### ML Processing Lifecycle
1. Status set to PROCESSING
2. 3-second deterministic delay simulates ML inference
3. Mock diagnosis result assigned
4. Status updated to COMPLETED

### Result Retrieval
1. Client polls `/api/prediction/{media_id}` every 2 seconds
2. Polling stops after 30-second timeout
3. UI updates with diagnosis and confidence
4. Treatment recommendations displayed

---

## 5. API Documentation

### Upload Endpoint
**Method**: POST `/api/upload-media`

**Request**: multipart/form-data
- `file`: JPEG/PNG, max 10MB
- `media_id`: Optional UUID
- `user_id`: string

**Response**:
```json
{
  "media_id": "uuid-string",
  "status": "UPLOADED",
  "message": "File uploaded successfully"
}
```

**Error Codes**: 400, 409, 413, 500

### Status Endpoint
**Method**: GET `/api/media-status/{media_id}`

**Response**:
```json
{
  "media_id": "uuid-string",
  "status": "PROCESSING|COMPLETED|FAILED",
  "created_at": "2024-02-16T08:30:00Z",
  "updated_at": "2024-02-16T08:30:03Z"
}
```

**Error Codes**: 404, 500

### Prediction Endpoint
**Method**: GET `/api/prediction/{media_id}`

**Response**:
```json
{
  "media_id": "uuid-string",
  "status": "COMPLETED",
  "result": "leaf_blight",
  "confidence": "87%",
  "created_at": "2024-02-16T08:30:00Z",
  "updated_at": "2024-02-16T08:30:03Z"
}
```

**Error Codes**: 404, 400, 500

### History Endpoint
**Method**: GET `/api/history?user_id={id}`

**Response**: Array of submission objects

**Error Codes**: 400, 500

### Status Mapping
- Client PENDING → Not uploaded
- Client UPLOADING → HTTP request in progress
- Client SUBMITTED → Server UPLOADED
- Client DIAGNOSED → Server COMPLETED
- Client FAILED → Upload/processing failed

---

## 6. Data Storage Design

### SQLite Schema
```sql
CREATE TABLE submission_queue (
    id TEXT PRIMARY KEY,
    media_path TEXT NOT NULL,
    media_type TEXT DEFAULT 'image/jpeg',
    status TEXT DEFAULT 'PENDING',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    uploaded_at DATETIME NULL,
    diagnosed_at DATETIME NULL,
    retry_count INTEGER DEFAULT 0,
    last_retry_at DATETIME NULL,
    user_id TEXT,
    sync_priority INTEGER DEFAULT 0
);

CREATE INDEX idx_submission_status ON submission_queue(status);
CREATE INDEX idx_user_submissions ON submission_queue(user_id, created_at);
```

### PostgreSQL Media Table
```sql
CREATE TABLE media (
    media_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(50),
    file_path VARCHAR(255),
    media_type VARCHAR(50),
    status VARCHAR(20) DEFAULT 'UPLOADED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    result VARCHAR(100),
    confidence VARCHAR(10),
    processing_time_ms INTEGER
);

CREATE INDEX idx_media_status ON media(status);
CREATE INDEX idx_user_media ON media(user_id, created_at);
```

### File Storage
- **Local**: App documents directory
- **Server**: /uploads
- **Naming**: {media_id}.jpg
- **Cleanup**: Scheduled server-side job for files older than 30 days

---

## 7. Background Processing

- Sync service polls every 5 minutes (configurable)
- Exponential backoff for failed uploads
- Max 5 retries per submission
- Connectivity detection triggers immediate queue processing
- ML simulation: 3-second deterministic delay, mock diagnosis assigned

---

## 8. Setup & Local Development

### Backend
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows
pip install -r requirements.txt
cp .env.example .env      # Edit database credentials
python -c "from app.database import engine; from app.models.base import Base; Base.metadata.create_all(bind=engine)"
python -m uvicorn app.main:app --reload --port 8000
```

### Frontend
```bash
cd crop_disease_app
flutter pub get
flutter run -d chrome --web-port 3001
# For mobile: flutter run (requires connected device/emulator)
```

### Environment
- Python 3.12+
- Flutter SDK 3.38.9+
- PostgreSQL for production
- SQLite for local dev
- Modern browser with WebRTC and File API
- 10GB free disk space

---

## 9. Known Limitations

- Simulated ML processing: no real disease recognition
- Single-device synchronization only
- Basic authentication (plain text passwords)
- Limited offline storage without automatic archival
- No real-time collaboration
- File upload max 10MB
- Network required for initial upload & result retrieval
- Limited language support: English, Hindi, Tamil, Telugu

---

## 10. Sprint-1 Technical Decisions

- **Offline-First**: Local SQLite ensures functionality without network; eventual consistency trade-offs
- **Simulated ML**: Placeholder with 3-second delay, focus on architecture & UX
- **REST Architecture**: Simple, async FastAPI, broad compatibility
- **Provider State Management**: Flutter-compatible reactive UI; limitations for large state trees

---

## 11. Non-Functional Requirements

- **Performance**: Upload <5s for 5MB, ML simulation 3s, local queries <100ms
- **Reliability**: Offline persistence, recovery from network interruptions
- **Offline Consistency**: Eventual consistency, atomic local transactions
- **Accessibility**: WCAG 2.1 AA compliance, TTS, large touch targets, adjustable font sizes
- **Idempotency**: media_id ensures no duplicate processing
