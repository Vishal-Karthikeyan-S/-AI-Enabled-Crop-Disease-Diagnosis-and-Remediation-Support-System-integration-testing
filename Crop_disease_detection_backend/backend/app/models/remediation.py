from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, JSON
from sqlalchemy.orm import relationship
from app.models.base import Base

class Remediation(Base):
    __tablename__ = "remediation"

    disease_id = Column(String, primary_key=True, index=True)
    disease_name = Column(String, nullable=False)
    general_advice = Column(String, nullable=True)
    
    # Relationships
    organic_steps = relationship("TreatmentStep", primaryjoin="and_(Remediation.disease_id==TreatmentStep.disease_id, TreatmentStep.type=='organic')", overlaps="treatment_steps")
    chemical_steps = relationship("TreatmentStep", primaryjoin="and_(Remediation.disease_id==TreatmentStep.disease_id, TreatmentStep.type=='chemical')", overlaps="treatment_steps")
    treatment_steps = relationship("TreatmentStep", back_populates="remediation")

class TreatmentStep(Base):
    __tablename__ = "treatment_steps"

    id = Column(Integer, primary_key=True, index=True)
    disease_id = Column(String, ForeignKey("remediation.disease_id"))
    step_number = Column(Integer)
    title = Column(String)
    description = Column(String)
    type = Column(String)  # 'organic', 'chemical', 'cultural', etc.
    safety_level = Column(String)  # 'safe', 'caution', 'warning', 'danger'
    dosage = Column(String, nullable=True)
    timing = Column(String, nullable=True)
    safety_warnings = Column(JSON, default=[]) # Stored as JSON list
    ppe_required = Column(JSON, default=[])    # Stored as JSON list
    weather_dependent = Column(Boolean, default=False)

    remediation = relationship("Remediation", back_populates="treatment_steps")
