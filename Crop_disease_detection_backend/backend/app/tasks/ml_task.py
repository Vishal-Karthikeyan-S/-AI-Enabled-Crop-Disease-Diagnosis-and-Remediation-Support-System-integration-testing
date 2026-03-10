from app.celery_worker import celery
from app.services.predict import predict_disease, predict_video
from app.database import SessionLocal
from app.models.media import Media


@celery.task
def process_ml(media_id, file_path):

    print("Running ML for:", media_id)

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

    finally:
        db.close()