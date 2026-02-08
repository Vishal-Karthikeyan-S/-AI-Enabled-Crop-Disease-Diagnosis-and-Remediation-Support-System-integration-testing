from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Default to localhost if environment variable not set
DATABASE_URL = "postgresql://user:password@localhost:5433/crop_diagnosis_db"

engine = create_engine(DATABASE_URL)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)
