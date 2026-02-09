from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Default to localhost if environment variable not set
DATABASE_URL = "postgresql://user:password@localhost:5433/crop_diagnosis_db"

# SQLAlchemy Database Setup
# connect_args={"check_same_thread": False} is needed only for SQLite.
# For PostgreSQL, we use the default connection arguments.
engine = create_engine(DATABASE_URL)

# SessionLocal is a factory for creating new database sessions.
# Each request will get its own session.
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)
