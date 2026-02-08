import os
import uuid

from fastapi import APIRouter, UploadFile, File, Depends
from sqlalchemy.orm import Session

from app.database import SessionLocal
from app.models.media import Media
from app.tasks.ml_task import process_ml

router = APIRouter(prefix="/api", tags=["Media"])

UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)


# ✅ DB Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# ✅ Upload API
@router.post("/upload-media")
def upload_media(file: UploadFile = File(...), db: Session = Depends(get_db)):

    # generate unique id
    media_id = str(uuid.uuid4())

    file_extension = file.filename.split(".")[-1]
    filename = f"{media_id}.{file_extension}"

    file_path = os.path.join(UPLOAD_FOLDER, filename)

    # save file locally
    with open(file_path, "wb") as buffer:
        buffer.write(file.file.read())

    # save metadata
    media = Media(
        media_id=media_id,
        media_type=file.content_type,
        status="UPLOADED",
        file_path=filename  # Store just the filename, we know it's in uploads/
    )

    db.add(media)
    db.commit()

    # ⭐ Trigger ML asynchronously
    # ⭐ Trigger ML synchronously
    try:
        process_ml(media_id, file_path)
    except Exception as e:
        print(f"Error processing ML: {e}")

    return {
        "media_id": media_id,
        "status": "UPLOADED",
        "message": "File uploaded. ML processing started."
    }
