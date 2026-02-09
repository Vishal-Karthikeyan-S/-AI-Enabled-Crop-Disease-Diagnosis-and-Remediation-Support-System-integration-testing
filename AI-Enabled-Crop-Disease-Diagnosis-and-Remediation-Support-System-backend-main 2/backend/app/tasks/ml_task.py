from app.database import SessionLocal
from app.models.media import Media
import time


# Synchronous ML Task
# This function simulates the Machine Learning processing pipeline.
# In a real production environment, this would likely be offloaded to a worker queue (like Celery).
def process_ml(media_id, file_path):

    db = SessionLocal()

    media = db.query(Media).filter(Media.media_id == media_id).first()

    if not media:
        return

    media.status = "PROCESSING"
    db.commit()

    print("ML STARTED")

    # simulate ML
    time.sleep(5)

    media.status = "COMPLETED"
    media.result = "leaf_blight"
    media.confidence = "92%"

    db.commit()
    db.close()

    print("ML COMPLETED")
