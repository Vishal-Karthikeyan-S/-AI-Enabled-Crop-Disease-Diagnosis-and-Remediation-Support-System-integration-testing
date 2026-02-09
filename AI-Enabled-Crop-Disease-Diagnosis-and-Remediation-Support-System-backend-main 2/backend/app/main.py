from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
import os
from fastapi.middleware.cors import CORSMiddleware
from app.routes import prediction
from app.routes import upload, process, status, history
from app.database import engine
from app.models import base

# Create database tables
base.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Farmer Crop Diagnosis Backend")
# Initialize FastAPI application with title.

# Configure CORS (Cross-Origin Resource Sharing)
# This is crucial for allowing the Flutter Web app (running on a different port)
# to communicate with this backend.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

app.include_router(upload.router)
app.include_router(process.router)
app.include_router(status.router)
app.include_router(prediction.router)
app.include_router(history.router)

# Mount uploads directory for static access
# This allows the frontend to display uploaded images by accessing 
# http://localhost:8000/uploads/{filename}
if not os.path.exists("uploads"):
    os.makedirs("uploads")
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

@app.get("/health")
def health():
    return {"status": "Backend running"}
