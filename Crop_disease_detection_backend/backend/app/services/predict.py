import torch
import cv2
import numpy as np
from PIL import Image
from torchvision import transforms
from app.services.labels import CLASS_NAMES
from app.services.model_loader import get_model

CONFIDENCE_THRESHOLD = 0.10

def predict_disease(image_path):

    try:
        # ✅ Safe image loading
        image = Image.open(image_path).convert("RGB")
    except Exception:
        return {
            "disease": "Unknown",
            "confidence": 0,
            "severity": None
        }

    try:
        transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize(
                mean=[0.485, 0.456, 0.406],
                std=[0.229, 0.224, 0.225]
            )
        ])

        image = transform(image).unsqueeze(0)

        model = get_model()
        model.eval()

        with torch.no_grad():
            outputs = model(image)
            probabilities = torch.softmax(outputs, dim=1)
            confidence, predicted = torch.max(probabilities, 1)

        confidence = confidence.item()
        predicted_class = CLASS_NAMES[predicted.item()]

        # 🔴 Unknown Handling
        if confidence < CONFIDENCE_THRESHOLD:
            return {
                "disease": "Unknown",
                "confidence": round(confidence, 2),
                "severity": None
            }

        # 🟡 Severity Classification
        if confidence >= 0.85:
            severity = "High"
        elif confidence >= 0.65:
            severity = "Medium"
        else:
            severity = "Low"

        return {
            "disease": predicted_class,
            "confidence": round(confidence, 2),
            "severity": severity
        }

    except Exception as e:
        print("Prediction error:", str(e))
        return {
            "disease": "Unknown",
            "confidence": 0,
            "severity": None
        }

def predict_video(video_path):

    cap = cv2.VideoCapture(video_path)
    predictions = []
    confidences = []

    frame_count = 0

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        frame_count += 1

        # Process every 15th frame (efficient)
        if frame_count % 15 != 0:
            continue

        frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        pil_image = Image.fromarray(frame)

        # Save temp frame for reuse of predict logic
        temp_path = "temp_frame.jpg"
        pil_image.save(temp_path)

        result = predict_disease(temp_path)

        if result["disease"] != "Unknown":
            predictions.append(result["disease"])
            confidences.append(result["confidence"])

    cap.release()

    if not predictions:
        return {
            "disease": "Unknown",
            "confidence": 0,
            "severity": None
        }

    # Majority vote
    final_disease = max(set(predictions), key=predictions.count)
    avg_confidence = sum(confidences) / len(confidences)

    # Assign severity again
    if avg_confidence >= 0.85:
        severity = "High"
    elif avg_confidence >= 0.65:
        severity = "Medium"
    else:
        severity = "Low"

    return {
        "disease": final_disease,
        "confidence": round(avg_confidence, 2),
        "severity": severity
    }