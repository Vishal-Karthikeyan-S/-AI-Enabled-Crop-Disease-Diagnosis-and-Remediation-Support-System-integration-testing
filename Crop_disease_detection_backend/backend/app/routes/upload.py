import os
import uuid
import shutil
import threading
from fastapi import APIRouter, UploadFile, File, Depends, HTTPException, BackgroundTasks
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.media import Media

router = APIRouter(prefix="/api", tags=["Media"])

UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

ALLOWED_TYPES = [
    "image/jpeg",
    "image/png",
    "image/webp",
    "video/mp4",
    "video/avi",
    "application/octet-stream"
    ]
MAX_FILE_SIZE = 20 * 1024 * 1024  # 20MB

# ✅ DB Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def run_ml_in_background(media_id: str, file_path: str):
    """Run ML prediction in a background thread and update DB with results."""
    from app.services.predict import predict_disease, predict_video
    db = SessionLocal()
    try:
        if file_path.lower().endswith((".mp4", ".avi")):
            result = predict_video(file_path)
        else:
            result = predict_disease(file_path)

        print("Prediction result:", result)

        media = db.query(Media).filter(Media.media_id == media_id).first()
        if media:
            media.status = "COMPLETED"
            media.result = result["disease"]
            media.confidence = result["confidence"]
            media.severity = result["severity"]
            db.commit()
    except Exception as e:
        print("ML Task Error:", str(e))
        media = db.query(Media).filter(Media.media_id == media_id).first()
        if media:
            media.status = "FAILED"
            db.commit()
    finally:
        db.close()


# ✅ Secure Upload API
@router.post("/upload-media")
async def upload_media(
    file: UploadFile = File(...),
    background_tasks: BackgroundTasks = BackgroundTasks(),
    db: Session = Depends(get_db)
):
    import traceback
    try:
        # ✅ Validate file type
        if file.content_type not in ALLOWED_TYPES:
            raise HTTPException(status_code=400, detail="Unsupported file type")

        # ✅ Read file contents
        contents = await file.read()

        # ✅ Validate file size
        if len(contents) > MAX_FILE_SIZE:
            raise HTTPException(status_code=400, detail="File too large")

        # Generate unique filename
        media_id = str(uuid.uuid4())
        ext = file.filename.split(".")[-1]
        filename = f"{media_id}.{ext}"
        file_path = os.path.join(UPLOAD_FOLDER, filename)

        # Save file safely
        with open(file_path, "wb") as buffer:
            buffer.write(contents)

        # Save to DB
        media = Media(
            media_id=media_id,
            media_type=file.content_type,
            status="UPLOADED"
        )

        db.add(media)
        db.commit()

        # 🔥 Run ML in background thread (non-blocking, no Redis needed)
        thread = threading.Thread(target=run_ml_in_background, args=(media_id, file_path), daemon=True)
        thread.start()

        return {
            "media_id": media_id,
            "status": "UPLOADED",
            "message": "Processing started"
        }
    except HTTPException:
        raise
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))
