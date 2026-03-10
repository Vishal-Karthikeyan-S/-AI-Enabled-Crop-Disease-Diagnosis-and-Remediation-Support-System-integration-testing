🌱 AI-Enabled Crop Disease Detection & Remediation System

An intelligent, scalable backend platform designed to assist farmers in early crop disease detection using AI-driven media analysis.

The system allows users to upload crop images/videos, processes them asynchronously using background workers, and returns disease diagnosis with severity analysis and remediation guidance.

📌 Project Overview

Crop diseases significantly reduce agricultural productivity. Early detection:

Prevents large-scale crop loss

Improves yield quality

Reduces manual inspection effort

Enables timely intervention

This project implements a production-oriented backend architecture capable of handling AI workloads efficiently and asynchronously.

🎯 Core Objectives

✅ Fast and reliable crop disease detection

✅ Asynchronous AI task processing

✅ Scalable backend architecture

✅ Secure media handling

✅ Cloud-ready deployment design

✅ Clean modular codebase

🏗️ System Architecture
High-Level Workflow
Client → FastAPI → Media Storage → Celery Worker → AI Model → Database → Response
Architecture Components
Component	Responsibility
FastAPI	API endpoints & request validation
Redis	Message broker
Celery	Background AI task processing
AI Model	Disease classification
Storage	Secure media handling
PostgreSQL (Planned)	Persistent data storage
⚙️ Technology Stack

FastAPI – High-performance async API framework

Uvicorn – ASGI server

Celery – Distributed task queue

Redis – Message broker

PostgreSQL – Relational database (planned integration)

Docker – Containerization (Sprint 2)

Pytest – Testing framework

🚀 Features Implemented (Sprint 0 & 1)

✅ Project architecture finalized

✅ Epics & user stories documented

✅ FastAPI backend setup

✅ Media upload endpoint

✅ File validation & sanitization

✅ Asynchronous Celery task pipeline

✅ Redis integration

✅ Logging setup

✅ Initial cloud deployment

🔄 Work in Progress

🔄 AI disease detection model integration

🔄 Severity classification logic

🔄 Remediation recommendation engine

🔄 Database integration

🔄 Enhanced error handling

🔄 API response standardization

🔮 Planned Enhancements (Sprint 2)

🚀 Complete AI inference pipeline

🚀 Docker containerization

🚀 Production deployment (Cloud)

🚀 Monitoring & observability

🚀 Performance benchmarking

🚀 API documentation improvements

📂 Project Structure
backend/
│── app/
│   ├── main.py
│   ├── celery.py
│   ├── routes/
│   ├── services/
│   └── utils/
│
│── uploads/
│── create_table.py
│── config.py
│── requirements.txt
│── README.md
🛠️ Setup Instructions
1️⃣ Clone Repository
git clone <your-repo-url>
cd backend
2️⃣ Create Virtual Environment
python -m venv venv

Activate:

Windows

venv\Scripts\activate

Mac/Linux

source venv/bin/activate
3️⃣ Install Dependencies
pip install -r requirements.txt
4️⃣ Start Redis

Ensure Redis is running:

redis-server
5️⃣ Run FastAPI Server
uvicorn app.main:app --reload

API Docs available at:

http://127.0.0.1:8000/docs
6️⃣ Start Celery Worker (New Terminal)
celery -A app.celery worker --loglevel=info
🔌 API Endpoints
📤 Upload Media
POST /upload

Description: Upload crop image/video for analysis
Response: Returns task ID for tracking

📊 Get Task Status
GET /status/{task_id}

Description: Retrieve processing status and diagnosis result

🧪 Testing

Run tests using:

pytest

Testing includes:

Unit testing

API validation

Async task testing

Integration testing (ongoing)

📊 Deployment Strategy

Environment-based configuration

Modular service architecture

Worker scalability support

Container-ready design

Cloud deployment compatibility

👥 Development Workflow

Agile sprint methodology

Feature-based branching

Incremental commits

Code reviews

Continuous improvement

🌾 Why This Project Matters

Agriculture is the backbone of many economies.
Leveraging AI for early disease detection:

Reduces farmer losses

Improves crop health

Promotes sustainable farming

Bridges AI & real-world impact

👨‍💻 Author

Developed as part of an academic engineering project focused on:

Scalable backend systems

Distributed task processing

AI integration

Production-ready engineering practices

⭐ Key Highlight

This project emphasizes:

✔ Backend architecture
✔ Asynchronous systems
✔ Scalability
✔ Cloud readiness
✔ Real-world AI application

—not just model development.