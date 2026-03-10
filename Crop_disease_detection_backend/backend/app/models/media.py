from sqlalchemy import Column, String, DateTime, Float
from datetime import datetime
from app.models.base import Base

class Media(Base):
    __tablename__ = "media"

    media_id = Column(String, primary_key=True, index=True)
    media_type = Column(String)

    status = Column(String, default="UPLOADED")

    created_at = Column(DateTime, default=datetime.utcnow)

    result = Column(String, nullable=True)
    confidence = Column(Float, nullable=True)  
    severity = Column(String, nullable=True)
