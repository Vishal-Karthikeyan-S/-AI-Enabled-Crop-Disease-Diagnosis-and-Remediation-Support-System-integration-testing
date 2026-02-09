# AI-Enabled Crop Disease Diagnosis System

This repository contains the integrated backend (FastAPI) and frontend (Flutter) for the AI-Enabled Crop Disease Diagnosis project.

## Project Structure

-   `AI-Enabled-Crop-Disease-Diagnosis-and-Remediation-Support-System-backend-main 2/backend`: **Python FastAPI Server**
-   `AI-Enabled-Crop-Disease-Diagnosis-and-Remediation-Support-System-backend-main 2/crop_disease_app`: **Flutter Mobile Application**

## Setup Instructions

### 1. Prerequisites

Ensure you have the following installed:
-   [Python 3.10+](https://www.python.org/downloads/)
-   [Flutter SDK](https://docs.flutter.dev/get-started/install)
-   [PostgreSQL](https://www.postgresql.org/download/)

### 2. Backend Setup

1.  Navigate to the backend directory:
    ```bash
    cd "AI-Enabled-Crop-Disease-Diagnosis-and-Remediation-Support-System-backend-main 2/backend"
    ```

2.  Create a virtual environment (optional but recommended):
    ```bash
    python -m venv venv
    source venv/bin/activate  # On macOS/Linux
    .\venv\Scripts\activate   # On Windows
    ```

3.  Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```

4.  Configure Environment Variables:
    -   Create a `.env` file in the `backend` directory.
    -   Copy the content from `.env.example` and update with your PostgreSQL credentials.
    -   Example `.env`:
        ```env
        DB_NAME=crop_diagnosis_db
        DB_USER=postgres
        DB_PASSWORD=your_password
        DB_HOST=localhost
        DB_PORT=5432
        ```

5.  Run the Backend Server:
    ```bash
    uvicorn app.main:app --reload --port 8000
    ```
    The server will start at `http://127.0.0.1:8000`.

### 3. Frontend Setup

1.  Navigate to the frontend directory:
    ```bash
    cd "AI-Enabled-Crop-Disease-Diagnosis-and-Remediation-Support-System-backend-main 2/crop_disease_app"
    ```

2.  Install Flutter dependencies:
    ```bash
    flutter pub get
    ```

3.  Run the App:
    -   **For Web (Chrome)**:
        ```bash
        flutter run -d chrome
        ```
    -   **For Mobile (Android/iOS)**:
        Connect your device or start an emulator, then run:
        ```bash
        flutter run
        ```

## Troubleshooting

-   **Backend Connection**: If running on an emulator, use `10.0.2.2` instead of `localhost` or `127.0.0.1` in the app's `SyncService.dart` (though we default to `http://localhost:8000` for web).
-   **Database**: Ensure your PostgreSQL server is running and the `crop_diagnosis_db` database exists. You can create it with:
    ```bash
    createdb crop_diagnosis_db
    ```
