import os
import torch
import torch.nn as nn
from torchvision import models
from app.services.labels import CLASS_NAMES

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

num_classes = len(CLASS_NAMES)

# Model path configuration supporting environments & Docker
_env_model = os.getenv("MODEL_PATH")
if _env_model and os.path.exists(_env_model):
    _model_path = _env_model
else:
    # Try looking in the top-level /models directory first (CI/CD layout)
    alt_path = os.path.join(os.path.dirname(__file__), "..", "..", "..", "..", "models", "plant_model.pth")
    if os.path.exists(alt_path):
        _model_path = os.path.normpath(alt_path)
    else:
        # Fallback to the original internal folder
        _model_path = os.path.join(os.path.dirname(__file__), "..", "model", "plant_model.pth")
        _model_path = os.path.normpath(_model_path)

# Lazy-loaded singleton — model is loaded only once, on first prediction call
_model = None

def get_model():
    global _model
    if _model is None:
        m = models.mobilenet_v2(weights=None)
        m.classifier[1] = nn.Linear(m.last_channel, num_classes)
        m.load_state_dict(torch.load(_model_path, map_location=device))
        m = m.to(device)
        m.eval()
        _model = m
        print(f"Model loaded from {_model_path}")
    return _model
