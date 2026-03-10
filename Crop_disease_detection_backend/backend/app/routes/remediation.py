from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.remediation import Remediation, TreatmentStep
from typing import List

router = APIRouter(prefix="/api/remediation", tags=["remediation"])

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/{disease_id}")
def get_remediation(
    disease_id: str, 
    severity: str = "medium",
    weather: str = "sunny",
    db: Session = Depends(get_db)
):
    # Find remediation data
    remediation = db.query(Remediation).filter(Remediation.disease_id == disease_id).first()
    
    if not remediation:
        # Fallback to name search if ID is a string name
        remediation = db.query(Remediation).filter(Remediation.disease_name == disease_id).first()

    if not remediation:
        raise HTTPException(status_code=404, detail="Remediation data not found")
    
    # Simulate weather-aware logic
    is_rainy = weather.lower() == "rainy"
    
    # Format response
    return {
        "disease_id": remediation.disease_id,
        "disease_name": remediation.disease_name,
        "severity_context": severity,
        "weather_context": weather,
        "organic_steps": [
            {
                "step_number": s.step_number,
                "title": s.title,
                "description": s.description,
                "type": s.type,
                "safety_level": s.safety_level,
                "dosage": s.dosage,
                "timing": s.timing,
                "safety_warnings": s.safety_warnings,
                "ppe_required": s.ppe_required,
                "weather_dependent": s.weather_dependent
            } for s in remediation.organic_steps
        ],
        "chemical_steps": [
            {
                "step_number": s.step_number,
                "title": s.title,
                "description": s.description,
                "type": s.type,
                "safety_level": s.safety_level,
                "dosage": s.dosage,
                "timing": s.timing,
                "safety_warnings": s.safety_warnings,
                "ppe_required": s.ppe_required,
                "weather_dependent": s.weather_dependent
            } for s in remediation.chemical_steps
        ],
        "general_advice": remediation.general_advice,
        "rain_warning": is_rainy,
        "weather_condition": weather
    }
