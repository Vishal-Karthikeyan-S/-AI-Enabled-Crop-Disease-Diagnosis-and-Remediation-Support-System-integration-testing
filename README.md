# AI-Enabled Crop Disease Diagnosis and Remediation Support System

This project is a modern, end-to-end MLOps application that detects crop diseases using a PyTorch machine learning model (MobileNetV2) and provides actionable remediation advice. It features a Flutter-based frontend for mobile/web users and a robust FastAPI backend.

The system is fully containerized with Docker, making it incredibly easy to run on any machine without needing to manually install Python, Flutter, or PyTorch.

---

## 🚀 How to Run the System Locally (Using Docker)

The easiest and recommended way to run this application is using **Docker**. This ensures your local environment exactly matches the production environment.

### Prerequisites
* [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running on your machine.
* Git installed on your machine.

### Step 1: Clone the Repository
```bash
git clone https://github.com/Vishal-Karthikeyan-S/-AI-Enabled-Crop-Disease-Diagnosis-and-Remediation-Support-System-integration-testing.git
cd -AI-Enabled-Crop-Disease-Diagnosis-and-Remediation-Support-System-integration-testing
```

### Step 2: Start the System
In the root directory of the project (where the `docker-compose.yml` file is located), run the following command:

```bash
docker-compose up --build
```

This command will automatically:
1. Download a lightweight Python environment.
2. Install all required PyTorch and FastAPI dependencies.
3. Download a Flutter environment and compile the Web Application.
4. Link the ML Model (`models/plant_model.pth`) into the backend.
5. Spin up both the Frontend and Backend servers simultaneously.

### Step 3: Access the Application
Once the terminal logs indicate that both services are running, you can access the system at:

* **Frontend (Flutter Web UI):** [http://localhost:3000](http://localhost:3000)
* **Backend API (FastAPI):** [http://localhost:8000](http://localhost:8000)
* **Backend API Interactive Docs:** [http://localhost:8000/docs](http://localhost:8000/docs)

**To stop the system:** Press `Ctrl + C` in your terminal, or run `docker-compose down`.

---

## 💻 Manual Setup (Without Docker)

If you prefer to run the systems natively on your machine for active development:

### 1. Backend Setup
Requires Python 3.10+
```bash
# Navigate to backend
cd Crop_disease_detection_backend/backend

# Install dependencies
pip install -r requirements.txt

# Run the backend
uvicorn app.main:app --reload
```
The backend will run on `http://localhost:8000`.

### 2. Frontend Setup
Requires Flutter SDK 3.38+
```bash
# Navigate to frontend
cd Front-end-with-remediation

# Get packages
flutter pub get

# Run the frontend (choose Chrome or Edge if prompted)
flutter run -d chrome
```

---

## 🤖 MLOps and CI/CD Architecture

This project is built with production-grade separation and automated CI/CD pipelines via **GitHub Actions**:

* **`/backend`**: The FastAPI service. Automatically tested (`pytest`) and built via the `Backend CI` pipeline on every push.
* **`/frontend`**: The Flutter UI. Automatically analyzed and compiled via the `Frontend CI` pipeline.
* **`/ml_pipeline` & `/models`**: The PyTorch model architecture. Triggering the `Model Workflow CI` pipeline retrains the system and saves the `.pth` artifact securely.

Changes pushed to specific directories intelligently trigger *only* their respective CI/CD pipelines, optimizing build times in a Monorepo structure.
