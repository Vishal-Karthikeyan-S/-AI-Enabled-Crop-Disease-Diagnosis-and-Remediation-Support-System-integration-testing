"""
Flask Backend for Crop Disease Diagnosis App

This backend server handles:
- Receiving photo uploads and text submissions from the frontend
- Deduplicating submissions using UUIDs
- Saving uploaded images to the filesystem
- Storing submission metadata in memory
- Returning diagnosis status (currently a placeholder)

In a production environment, this would:
- Use a real database (PostgreSQL, MongoDB)
- Integrate with an AI model for actual crop disease diagnosis
- Implement authentication and authorization
- Use cloud storage for images (AWS S3, Google Cloud Storage)
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import time
import base64
import os
from pathlib import Path

app = Flask(__name__)
CORS(app)  # Enable CORS to allow requests from the React frontend

# Create uploads directory for storing crop disease images
UPLOAD_DIR = Path(__file__).parent / 'uploads'
UPLOAD_DIR.mkdir(exist_ok=True)

# In-memory storage for deduplication and submission tracking
# In a real app, this would be PostgreSQL/Redis/MongoDB
received_ids = set()      # Track which submission IDs we've already processed
submissions = []          # Store all received submissions

@app.route('/api/sync', methods=['POST'])
def sync_data():
    """
    Sync endpoint - receives a batch of submissions from the frontend
    
    Expected Payload:
    {
        "submissions": [
            {
                "id": "uuid-string",
                "data": {
                    "text": "Crop description",
                    "image": "data:image/jpeg;base64,..."
                },
                "createdAt": "ISO timestamp",
                "status": "queued"
            }
        ]
    }
    
    Returns:
    {
        "status": "success",
        "processed": number of new items,
        "skipped": number of duplicates,
        "message": "Data synced successfully..."
    }
    """
    data = request.json
    incoming_submissions = data.get('submissions', [])
    
    processed_count = 0
    skipped_count = 0
    
    for sub in incoming_submissions:
        sub_id = sub.get('id')
        
        # Skip submissions without an ID
        if not sub_id:
            continue
        
        # Deduplication: skip if we've already processed this ID
        if sub_id in received_ids:
            skipped_count += 1
            print(f"[DEDUPE] Skipped duplicate submission: {sub_id}")
            continue
        
        # Handle image data if present
        if 'data' in sub and 'image' in sub['data']:
            image_data = sub['data']['image']
            
            # Check if it's a base64 encoded image
            if image_data and image_data.startswith('data:image'):
                try:
                    # Extract base64 data (remove the "data:image/jpeg;base64," prefix)
                    header, encoded = image_data.split(',', 1)
                    image_bytes = base64.b64decode(encoded)
                    
                    # Determine file extension from the data URL header
                    ext = 'jpg'
                    if 'png' in header:
                        ext = 'png'
                    elif 'jpeg' in header or 'jpg' in header:
                        ext = 'jpg'
                    
                    # Save image with UUID as filename
                    image_filename = f"{sub_id}.{ext}"
                    image_path = UPLOAD_DIR / image_filename
                    with open(image_path, 'wb') as f:
                        f.write(image_bytes)
                    
                    # Store filename in submission, remove base64 to save memory
                    sub['data']['image_filename'] = image_filename
                    sub['data']['image'] = None  # Clear base64 data
                    
                    print(f"[IMAGE] Saved image: {image_filename}")
                except Exception as e:
                    print(f"[ERROR] Failed to save image: {e}")
        
        # Store the submission
        received_ids.add(sub_id)
        
        # Add server-side metadata
        sub['received_at'] = time.time()
        sub['server_status'] = "diagnosis_pending"  # Placeholder for AI diagnosis
        
        submissions.append(sub)
        processed_count += 1
        print(f"[RECV] New submission: {sub_id}")

    # Return success response
    response = {
        "status": "success",
        "processed": processed_count,
        "skipped": skipped_count,
        "message": "Data synced successfully. Diagnosis is pending."
    }
    
    return jsonify(response), 200

@app.route('/api/submissions', methods=['GET'])
def get_submissions():
    """
    Debug endpoint to view all stored submissions
    
    This is useful for:
    - Debugging during development
    - Verifying that submissions are being received
    - Checking the structure of stored data
    """
    return jsonify(submissions), 200

if __name__ == '__main__':
    print("🌾 Starting Crop Disease Diagnosis Backend on port 5000...")
    print(f"📁 Images will be saved to: {UPLOAD_DIR.absolute()}")
    app.run(debug=True, port=5000)
