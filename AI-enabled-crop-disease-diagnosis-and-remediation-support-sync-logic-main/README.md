# 🌾 Crop Disease Diagnosis - Offline-First PWA

An offline-first Progressive Web App for crop disease diagnosis with photo upload capabilities. Built with React and Flask, featuring automatic sync and upload history tracking.

## Features

- ✅ **Offline-First Architecture**: Works without internet connection
- 📷 **Photo Upload**: Upload crop disease photos with optional text descriptions
- 💾 **Automatic Sync**: Automatically syncs when device comes back online
- 📋 **Upload History**: Track all uploads with status (Pending/Synced)
- 🔄 **Database Recovery**: Automatic error handling and manual reset option
- 🎯 **Deduplication**: Server-side deduplication prevents duplicate uploads

## Tech Stack

### Frontend
- **React** - UI framework
- **Vite** - Build tool and dev server
- **IndexedDB** (via `idb`) - Offline storage
- **UUID** - Unique ID generation

### Backend
- **Flask** - Python web framework
- **Flask-CORS** - Cross-origin resource sharing
- **Base64** - Image encoding/decoding

## Project Structure

```
glue-sync/
├── frontend/
│   ├── src/
│   │   ├── App.jsx              # Main React component
│   │   ├── App.css              # Styling
│   │   └── sync-engine/
│   │       ├── db.js            # IndexedDB operations
│   │       └── SyncManager.js   # Sync logic
│   └── package.json
│
└── backend/
    ├── app.py                   # Flask server
    ├── uploads/                 # Uploaded images
    └── requirements.txt
```

## Installation

### Prerequisites
- Node.js (v16+)
- Python (v3.8+)
- npm or yarn

### Frontend Setup

```bash
cd frontend
npm install
npm run dev
```

The frontend will run on **http://localhost:5173**

### Backend Setup

```bash
cd backend
pip install flask flask-cors
python app.py
```

The backend will run on **http://localhost:5000**

## Usage

1. **Open the app**: Navigate to http://localhost:5173
2. **Upload a photo**: Click "📷 Add Photo" and select a crop image
3. **Add description** (optional): Enter crop details or symptoms
4. **Submit**: Click "📤 Submit" (online) or "💾 Save Offline" (offline)
5. **View history**: Check the "📋 Upload History" section

### Testing Offline Mode

1. Open browser DevTools (F12)
2. Go to Network tab
3. Check "Offline" mode
4. Upload photos - they'll be queued
5. Uncheck "Offline" - automatic sync will trigger

## How It Works

### Offline Storage
- Submissions are saved to IndexedDB as soon as created
- Images are stored as base64 strings
- Data persists across page refreshes

### Sync Process
1. User submits photo → Saved to IndexedDB queue
2. If online → Immediately syncs to backend
3. If offline → Waits in queue
4. When back online → Automatic sync
5. After sync → Moved to history with timestamp

### Database Schema

**offline-queue** (pending uploads)
```javascript
{
  id: "uuid",
  data: { text: "...", image: "data:image/..." },
  createdAt: "ISO timestamp",
  status: "queued"
}
```

**upload-history** (synced uploads)
```javascript
{
  id: "uuid",
  data: { text: "...", image: "data:image/..." },
  createdAt: "ISO timestamp",
  status: "synced",
  syncedAt: "ISO timestamp"
}
```

## API Endpoints

### POST /api/sync
Sync pending submissions to the server

**Request:**
```json
{
  "submissions": [
    {
      "id": "uuid",
      "data": {
        "text": "Crop description",
        "image": "data:image/jpeg;base64,..."
      },
      "createdAt": "2026-02-07T12:00:00Z",
      "status": "queued"
    }
  ]
}
```

**Response:**
```json
{
  "status": "success",
  "processed": 1,
  "skipped": 0,
  "message": "Data synced successfully. Diagnosis is pending."
}
```

### GET /api/submissions
Get all stored submissions (debug endpoint)

## Troubleshooting

### Database Errors

If you see "connection is blocking a database upgrade":

1. Close all browser tabs with the app
2. Open a fresh tab at http://localhost:5173
3. Or click the "🔄 Reset DB" button in the header

### Images Not Saving

Check that the `backend/uploads/` directory exists and has write permissions.

### Sync Failing

- Verify backend is running on port 5000
- Check browser console for error messages
- Ensure CORS is enabled in Flask

## Development

### Adding Comments
All code files include comprehensive comments explaining:
- Module purpose and functionality
- Function parameters and return values
- Error handling strategies
- Design decisions

### Code Style
- **Frontend**: ES6+ JavaScript with React hooks
- **Backend**: Python with Flask best practices
- **Comments**: JSDoc for JavaScript, docstrings for Python

## Future Enhancements

- [ ] AI-powered crop disease diagnosis
- [ ] User authentication
- [ ] Cloud storage for images (AWS S3, Google Cloud)
- [ ] Real database (PostgreSQL, MongoDB)
- [ ] Push notifications for diagnosis results
- [ ] PWA installation prompt
- [ ] Service worker for true offline capability

## License

This project is for educational purposes.

## Author

Built as part of an AI-enabled crop disease diagnosis and remediation support system.
