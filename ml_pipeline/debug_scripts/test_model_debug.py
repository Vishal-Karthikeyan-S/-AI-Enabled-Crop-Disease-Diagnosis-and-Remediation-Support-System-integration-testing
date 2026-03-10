import torch
from torchvision import models, transforms
import torch.nn as nn
from PIL import Image
import os
import sys

# Import our list of 29 labels
try:
    from app.services.labels import CLASS_NAMES
except ImportError:
    # Fallback if app structure isn't in path
    CLASS_NAMES = [f"Class_{i}" for i in range(29)]

def test_single_image(img_path):
    print(f"\n--- Testing Image: {os.path.basename(img_path)} ---")
    
    # 1. Setup Model (Must match training architecture)
    model = models.mobilenet_v2(weights=None)
    model.classifier[1] = nn.Linear(model.last_channel, 29)
    
    # 2. Load Weights
    model_path = "app/model/plant_model.pth"
    try:
        model.load_state_dict(torch.load(model_path, map_location='cpu'))
        model.eval()
        print("✅ Model loaded successfully.")
    except Exception as e:
        print(f"❌ Error loading model: {e}")
        return

    # 3. Preprocess Image
    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])

    try:
        img = Image.open(img_path).convert('RGB')
        img_tensor = transform(img).unsqueeze(0)
    except Exception as e:
        print(f"❌ Error opening image: {e}")
        return

    # 4. Predict
    with torch.no_grad():
        outputs = model(img_tensor)
        probabilities = torch.softmax(outputs, dim=1)
        
        # Get Top 5
        top_probs, top_idxs = torch.topk(probabilities, k=5)
        
    print("\nTop 5 Predictions:")
    for i in range(5):
        idx = top_idxs[0][i].item()
        prob = top_probs[0][i].item() * 100
        label = CLASS_NAMES[idx] if idx < len(CLASS_NAMES) else f"Unknown_Index_{idx}"
        print(f" {i+1}. {label:.<30} {prob:.2f}%")

if __name__ == "__main__":
    # Check if an image was provided, otherwise use the first one in /uploads
    test_img = ""
    if len(sys.argv) > 1:
        test_img = sys.argv[1]
    else:
        upload_dir = "uploads"
        if os.path.exists(upload_dir):
            files = [f for f in os.listdir(upload_dir) if f.lower().endswith(('.png', '.jpg', '.jpeg'))]
            if files:
                test_img = os.path.join(upload_dir, files[0])
    
    if test_img and os.path.exists(test_img):
        test_single_image(test_img)
    else:
        print("❌ No image found to test. Please provide a path: python test_model_debug.py your_image.jpg")
