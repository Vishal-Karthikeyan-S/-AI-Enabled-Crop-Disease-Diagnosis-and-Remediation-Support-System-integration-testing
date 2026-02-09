from app.database import engine
from app.models.media import Media
from sqlalchemy import text

# Drop the media table
try:
    with engine.connect() as conn:
        conn.execute(text("DROP TABLE IF EXISTS media CASCADE"))
        conn.commit()
    print("Dropped media table successfully")
except Exception as e:
    print(f"Error dropping table: {e}")
