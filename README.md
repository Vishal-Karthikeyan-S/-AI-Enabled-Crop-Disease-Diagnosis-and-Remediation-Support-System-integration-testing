# AI-Enabled Crop Disease Diagnosis & Remediation Support System

This project is a comprehensive **Offline-First** solution for diagnosing crop diseases, allowing farmers to capture images and get remediation advice even with intermittent internet connectivity.

It integrates a robust **FastAPI Backend** with a responsive **Flutter Frontend**, featuring a custom **Sync Engine** that ensures data consistency across devices.

## 🚀 Key Features (Integration Highlights)

### 1. Offline-First Architecture
-   **Local Queueing**: Submissions are saved locally (using SQLite on Mobile, In-Memory on Web) when offline.
-   **Seamless Experience**: Users can continue to take photos and view history without an active connection.

### 2. Intelligent Auto-Sync
-   **Connectivity Detection**: The app automatically detects when the device comes online.
-   **Batch Uploads**: Pending submissions are automatically uploaded in the background.
-   **Resilience**: Failed uploads are retried automatically without user intervention.

### 3. Backend Integration (FastAPI)
-   **Deduplication**: The server handles duplicate uploads gracefully using client-generated IDs, preventing data redundancy.
-   **Static File Serving**: Images are securely stored and served for history playback.
-   **CORS Support**: Fully configured for Web and Mobile clients.

---

## 🛠 Project Structure

-   `AI-Enabled-Crop-Disease-Diagnosis-and-Remediation-Support-System-backend-main 2/backend`: **Python FastAPI Server**
    -   Handles Uploads, AI Diagnosis (Mock/Real), and Data Persistence (PostgreSQL).
-   `AI-Enabled-Crop-Disease-Diagnosis-and-Remediation-Support-System-backend-main 2/crop_disease_app`: **Flutter Mobile/Web App**
    -   Implements the UI, Camera Logic, and the **SyncService**.

---

## ⚙️ Setup & Run Instructions

### Prerequisites
-   [Python 3.10+](https://www.python.org/downloads/)
-   [Flutter SDK](https://docs.flutter.dev/get-started/install)
-   [PostgreSQL](https://www.postgresql.org/download/)

### Step 1: Backend Setup
1.  Navigate to the backend:
    ```bash
    cd "AI-Enabled-Crop-Disease-Diagnosis-and-Remediation-Support-System-backend-main 2/backend"
    ```
2.  Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```
3.  Configure Database:
    -   Create a `.env` file (see `.env.example`).
    -   Ensure PostgreSQL is running and the database exists (`createdb crop_diagnosis_db`).
4.  Run Server:
    ```bash
    uvicorn app.main:app --reload --port 8000
    ```

### Step 2: Frontend Setup
1.  Navigate to the app:
    ```bash
    cd "AI-Enabled-Crop-Disease-Diagnosis-and-Remediation-Support-System-backend-main 2/crop_disease_app"
    ```
2.  Get dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the App:
    -   **Web**: `flutter run -d chrome`
    -   **Mobile**: `flutter run`

---

## 🧪 Testing the Integration

1.  Start the Backend and Frontend.
2.  **Go Offline**: Disconnect your device/browser from the internet.
3.  **Submit a Photo**: The app will save it as "Saved (not uploaded)".
4.  **Go Online**: Reconnect to the internet.
5.  **Watch it Sync**: The app will automatically upload the photo, and the status will change to "Uploaded" -> "Diagnosed".
