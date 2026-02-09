from sqlalchemy import Column, String, DateTime
from datetime import datetime
from app.models.base import Base


class Media(Base):
    __tablename__ = "media"

    media_id = Column(String, primary_key=True, index=True)
    media_type = Column(String)

    status = Column(String, default="UPLOADED")

    created_at = Column(DateTime, default=datetime.utcnow)
    
    # ⭐ NEW FIELDS
    user_id = Column(String, index=True, nullable=True)

    # ⭐ NEW FIELDS (VERY IMPORTANT)
    # Result of the diagnosis (e.g., "Leaf Blight")
    result = Column(String, nullable=True)
    # Confidence score of the diagnosis (e.g., "98%")
    confidence = Column(String, nullable=True)
    
    # Filename of the stored image.
    # Frontend constructs the URL using this: BASE_URL + /uploads/ + file_path
    file_path = Column(String, nullable=True)
