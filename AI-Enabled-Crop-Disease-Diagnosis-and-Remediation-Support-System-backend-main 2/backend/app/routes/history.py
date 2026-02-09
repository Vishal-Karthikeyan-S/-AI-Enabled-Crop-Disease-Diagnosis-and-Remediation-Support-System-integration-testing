from fastapi import APIRouter
from app.database import SessionLocal
from app.models.media import Media

router = APIRouter(prefix="/api", tags=["History"])

@router.get("/history")
def get_history(user_id: str = None):
    """
    Fetch the history of all uploaded media and their diagnosis results.
    Returns a list of records sorted by creation time (newest first).
    """
    db = SessionLocal()
    try:
        # Fetch all media records ordered by creation time (descending)
        query = db.query(Media)
        
        # Filter by user_id if provided
        if user_id:
            query = query.filter(Media.user_id == user_id)
            
        history = query.order_by(Media.created_at.desc()).all()
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
