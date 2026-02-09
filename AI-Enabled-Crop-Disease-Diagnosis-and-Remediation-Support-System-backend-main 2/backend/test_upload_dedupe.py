import requests
import uuid
import os

BASE_URL = "http://127.0.0.1:8000/api"
UPLOAD_URL = f"{BASE_URL}/upload-media"

# Create a dummy image file
dummy_filename = "test_image.jpg"
with open(dummy_filename, "wb") as f:
    f.write(os.urandom(1024))  # 1KB of random data

try:
    # 1. Generate a client-side ID
    client_id = str(uuid.uuid4())
    print(f"Testing with Client ID: {client_id}")

    # 2. First Upload
    print("\n--- Attempting First Upload ---")
    with open(dummy_filename, "rb") as f:
        files = {"file": (dummy_filename, f, "image/jpeg")}
        data = {"media_id": client_id}
        response = requests.post(UPLOAD_URL, files=files, data=data)
    
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")

    if response.status_code == 200:
        print("✅ First upload successful.")
    else:
        print("❌ First upload failed.")
        exit(1)

    # 3. Second Upload (Deduplication Test)
    print("\n--- Attempting Second Upload (Same ID) ---")
    with open(dummy_filename, "rb") as f:
        files = {"file": (dummy_filename, f, "image/jpeg")}
        data = {"media_id": client_id}
        response = requests.post(UPLOAD_URL, files=files, data=data)

    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")

    if response.status_code == 200 and "deduplicated" in response.json().get("message", "").lower():
        print("✅ Deduplication successful.")
    else:
        print("❌ Deduplication failed or message not as expected.")

except Exception as e:
    print(f"An error occurred: {e}")
finally:
    if os.path.exists(dummy_filename):
        os.remove(dummy_filename)
