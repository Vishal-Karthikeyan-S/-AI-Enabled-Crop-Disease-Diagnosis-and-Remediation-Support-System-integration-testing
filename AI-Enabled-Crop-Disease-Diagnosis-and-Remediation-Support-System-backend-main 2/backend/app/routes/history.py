from fastapi import APIRouter
from app.database import SessionLocal
from app.models.media import Media

router = APIRouter(prefix="/api", tags=["History"])

@router.get("/history")
def get_history():
    db = SessionLocal()
    try:
        # Fetch all media records ordered by creation time (descending)
        history = db.query(Media).order_by(Media.created_at.desc()).all()
        return [
            {
                "media_id": m.media_id,
                "status": m.status,
                "created_at": str(m.created_at) if m.created_at else None,
                "result": m.result,
                "confidence": m.confidence,
                "file_path": m.file_path
            } for m in history
        ]
    finally:
        db.close()
