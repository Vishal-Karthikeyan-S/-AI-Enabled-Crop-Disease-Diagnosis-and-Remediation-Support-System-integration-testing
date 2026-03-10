from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes import prediction
from app.routes import upload, process, status, remediation as remediation_router
from app.models.base import Base
from app.models import media, remediation as remediation_model
from app.database import engine

from fastapi import Request
import time

app = FastAPI(title="Farmer Crop Diagnosis Backend")

# ✅ Logging middleware to debug connection issues
@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    duration = time.time() - start_time
    print(f"Request: {request.method} {request.url.path} - Status: {response.status_code} - Duration: {duration:.4f}s")
    return response

# ✅ Liberal CORS for development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

Base.metadata.create_all(bind=engine)
app.include_router(upload.router)
app.include_router(process.router)
app.include_router(status.router)
app.include_router(prediction.router)
app.include_router(remediation_router.router)

@app.get("/health")
def health():
    return {"status": "Backend running"}


@app.get("/")
def root():
    return {"message": "API is running"}
