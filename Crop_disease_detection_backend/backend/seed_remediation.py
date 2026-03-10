import sys
import os
from sqlalchemy.orm import Session
from app.database import SessionLocal, engine
from app.models.base import Base
from app.models.remediation import Remediation, TreatmentStep
from app.services.labels import CLASS_NAMES

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
        
        # 1. Paddy Blast (Index 0)
        paddy_blast = Remediation(
            disease_id="0",
            disease_name="Paddy Blast",
            general_advice="Maintain proper water levels and avoid excessive nitrogen application."
        )
        db.add(paddy_blast)
        
        paddy_blast_steps = [
            TreatmentStep(
                disease_id="0",
                step_number=1,
                title="Apply Tricyclazole",
                description="Spray Tricyclazole 75% WP at recommended dosage.",
                type="chemical",
                safety_level="warning",
                dosage="0.6 g per liter",
                timing="Early morning or late evening",
                safety_warnings=["Avoid skin contact", "Keep away from children"],
                ppe_required=["Gloves", "Mask"],
                weather_dependent=True
            ),
            TreatmentStep(
                disease_id="0",
                step_number=1,
                title="Use Neem Oil",
                description="Spray 5% Neem oil solution on the leaves.",
                type="organic",
                safety_level="safe",
                dosage="5 ml per liter",
                timing="Once every 10 days",
                ppe_required=["Gloves"],
                weather_dependent=False
            )
        ]
        db.add_all(paddy_blast_steps)

        # 2. Tomato Late Blight (Index 3)
        tomato_late_blight = Remediation(
            disease_id="3",
            disease_name="Tomato Late Blight",
            general_advice="Remove and destroy infected plants immediately to prevent spread."
        )
        db.add(tomato_late_blight)
        
        tomato_steps = [
            TreatmentStep(
                disease_id="3",
                step_number=1,
                title="Copper-based Fungicide",
                description="Apply organic copper-based fungicide to protect healthy foliage.",
                type="organic",
                safety_level="caution",
                dosage="3 g per liter",
                timing="Every 7-10 days",
                ppe_required=["Gloves", "Mask"],
                weather_dependent=True
            ),
            TreatmentStep(
                disease_id="3",
                step_number=1,
                title="Mancozeb Spray",
                description="Spray Mancozeb at the first sign of disease outbreak.",
                type="chemical",
                safety_level="warning",
                dosage="2.5 g per liter",
                timing="Immediately upon detection",
                safety_warnings=["Do not spray near water sources", "Toxic to bees"],
                ppe_required=["Gloves", "Mask", "Protective clothing"],
                weather_dependent=True
            )
        ]
        db.add_all(tomato_steps)

        # 3. Potato Late Blight (Index 5)
        potato_late_blight = Remediation(
            disease_id="5",
            disease_name="Potato Late Blight",
            general_advice="Ensure good soil drainage and avoid overhead irrigation."
        )
        db.add(potato_late_blight)
        
        potato_steps = [
            TreatmentStep(
                disease_id="5",
                step_number=1,
                title="Bio-Fungicide (Bacillus subtilis)",
                description="Apply liquid formulation of Bacillus subtilis to the soil and foliage.",
                type="organic",
                safety_level="safe",
                dosage="10 ml per liter",
                timing="Twice a month",
                ppe_required=[],
                weather_dependent=False
            )
        ]
        db.add_all(potato_steps)

        # Add generic data for others to ensure they have at least something
        for i, name in enumerate(CLASS_NAMES):
            str_id = str(i)
            # Skip if we already added real data for this ID
            if str_id in ["0", "3", "5"]:
                continue
                
            if not db.query(Remediation).filter_by(disease_id=str_id).first():
                rem = Remediation(
                    disease_id=str_id,
                    disease_name=name,
                    general_advice=f"Standard care for {name}."
                )
                db.add(rem)
                db.add(TreatmentStep(
                    disease_id=str_id,
                    step_number=1,
                    title="Monitor Plant",
                    description="Keep a close eye on the plant and report any changes.",
                    type="organic",
                    safety_level="safe"
                ))

        db.commit()
        print("Seeding complete!")
        
    except Exception as e:
        db.rollback()
        print(f"Error seeding database: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_data()
