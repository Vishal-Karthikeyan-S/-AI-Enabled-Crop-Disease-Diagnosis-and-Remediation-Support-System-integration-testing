import sys
import os
from sqlalchemy.orm import Session
from app.database import SessionLocal, engine
from app.models.base import Base
from app.models.remediation import Remediation, TreatmentStep
from app.services.labels import CLASS_NAMES

def get_id(name):
    """Find the index of a name in CLASS_NAMES, returning it as a string."""
    try:
        return str(CLASS_NAMES.index(name))
    except ValueError:
        # Fallback search if names don't match exactly
        for i, class_name in enumerate(CLASS_NAMES):
            if name.lower() in class_name.lower() or class_name.lower() in name.lower():
                return str(i)
        return None

def seed_data():
    # Create tables if they don't exist
    Base.metadata.create_all(bind=engine)
    
    db: Session = SessionLocal()
    
    try:
        # Clear existing data for a clean seed
        db.query(TreatmentStep).delete()
        db.query(Remediation).delete()
        db.commit()

        print("Seeding remediation data...")
        
        # Define remediation entries with their data
        remediations = [
            {
                "name": "Bacterial leaf blight",  # Matches Paddy/Rice disease in labels
                "general_advice": "Maintain proper water levels and avoid excessive nitrogen application.",
                "steps": [
                    {
                        "title": "Apply Tricyclazole",
                        "description": "Spray Tricyclazole 75% WP at recommended dosage.",
                        "type": "chemical",
                        "safety_level": "warning",
                        "dosage": "0.6 g per liter",
                        "timing": "Early morning or late evening",
                        "safety_warnings": ["Avoid skin contact", "Keep away from children"],
                        "ppe_required": ["Gloves", "Mask"],
                        "weather_dependent": True
                    },
                    {
                        "title": "Use Neem Oil",
                        "description": "Spray 5% Neem oil solution on the leaves.",
                        "type": "organic",
                        "safety_level": "safe",
                        "dosage": "5 ml per liter",
                        "timing": "Once every 10 days",
                        "ppe_required": ["Gloves"],
                        "weather_dependent": False
                    }
                ]
            },
            {
                "name": "Tomato Late Blight",
                "general_advice": "Remove and destroy infected plants immediately to prevent spread.",
                "steps": [
                    {
                        "title": "Copper-based Fungicide",
                        "description": "Apply organic copper-based fungicide to protect healthy foliage.",
                        "type": "organic",
                        "safety_level": "caution",
                        "dosage": "3 g per liter",
                        "timing": "Every 7-10 days",
                        "ppe_required": ["Gloves", "Mask"],
                        "weather_dependent": True
                    },
                    {
                        "title": "Mancozeb Spray",
                        "description": "Spray Mancozeb at the first sign of disease outbreak.",
                        "type": "chemical",
                        "safety_level": "warning",
                        "dosage": "2.5 g per liter",
                        "timing": "Immediately upon detection",
                        "safety_warnings": ["Do not spray near water sources", "Toxic to bees"],
                        "ppe_required": ["Gloves", "Mask", "Protective clothing"],
                        "weather_dependent": True
                    }
                ]
            },
            {
                "name": "Potato Late Blight",
                "general_advice": "Ensure good soil drainage and avoid overhead irrigation.",
                "steps": [
                    {
                        "title": "Bio-Fungicide (Bacillus subtilis)",
                        "description": "Apply liquid formulation of Bacillus subtilis to the soil and foliage.",
                        "type": "organic",
                        "safety_level": "safe",
                        "dosage": "10 ml per liter",
                        "timing": "Twice a month",
                        "ppe_required": [],
                        "weather_dependent": False
                    }
                ]
            }
        ]

        added_ids = set()
        for rem_data in remediations:
            str_id = get_id(rem_data["name"])
            if str_id:
                if str_id in added_ids:
                    continue
                added_ids.add(str_id)
                print(f"Adding data for {rem_data['name']} (ID: {str_id})")
                rem = Remediation(
                    disease_id=str_id,
                    disease_name=rem_data["name"],
                    general_advice=rem_data["general_advice"]
                )
                db.add(rem)
                
                for step_data in rem_data["steps"]:
                    step = TreatmentStep(
                        disease_id=str_id,
                        step_number=1, # Simplified for now
                        title=step_data["title"],
                        description=step_data["description"],
                        type=step_data["type"],
                        safety_level=step_data["safety_level"],
                        dosage=step_data.get("dosage"),
                        timing=step_data.get("timing"),
                        safety_warnings=step_data.get("safety_warnings", []),
                        ppe_required=step_data.get("ppe_required", []),
                        weather_dependent=step_data.get("weather_dependent", False)
                    )
                    db.add(step)
            else:
                print(f"Warning: Could not find ID for {rem_data['name']}")

        # Add generic data for all other classes
        for i, name in enumerate(CLASS_NAMES):
            str_id = str(i)
            # Skip if we already added real data for this ID
            if str_id in added_ids:
                continue
                
            rem = Remediation(
                disease_id=str_id,
                disease_name=name,
                general_advice=f"Standard care for {name}. Consult a local expert if symptoms persist."
            )
            db.add(rem)
            db.add(TreatmentStep(
                disease_id=str_id,
                step_number=1,
                title="Monitor and Isolate",
                description=f"Monitor the spread of {name} and isolate affected plants.",
                type="organic",
                safety_level="safe"
            ))

        db.commit()
        print("Seeding complete!")
        
    except Exception as e:
        db.rollback()
        print(f"Error seeding database: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    seed_data()

