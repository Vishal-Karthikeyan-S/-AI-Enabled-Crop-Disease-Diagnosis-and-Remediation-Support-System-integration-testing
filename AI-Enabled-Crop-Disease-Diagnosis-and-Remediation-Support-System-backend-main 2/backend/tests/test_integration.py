import pytest
import httpx
import uuid
import os

# --- CONFIGURATION ---
BASE_URL = "http://localhost:8000"
TEST_MEDIA_ID = str(uuid.uuid4())
TEST_IMAGE_PATH = "test_image.jpg"

@pytest.fixture(scope="module")
def test_client():
    with httpx.Client(base_url=BASE_URL, timeout=10.0) as client:
        yield client

def create_dummy_image():
    # Create a small dummy image for testing upload
    with open(TEST_IMAGE_PATH, "wb") as f:
        f.write(os.urandom(1024))

def remove_dummy_image():
    if os.path.exists(TEST_IMAGE_PATH):
        os.remove(TEST_IMAGE_PATH)

# --- TESTS ---

def test_backend_health(test_client):
    """TC_HEALTH_01: Verify Backend is Running"""
    response = test_client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "Backend running"}

def test_upload_offline_sync(test_client):
    """TC_OFFLINE_01: Verify Offline Upload Sync (Client Generated ID)"""
    create_dummy_image()
    try:
        with open(TEST_IMAGE_PATH, "rb") as f:
            files = {"file": ("test_image.jpg", f, "image/jpeg")}
            data = {"media_id": TEST_MEDIA_ID} # Simulate Offline ID
            
            response = test_client.post("/api/upload-media", files=files, data=data)
            
            assert response.status_code in [200, 201]
            json_data = response.json()
            assert json_data["media_id"] == TEST_MEDIA_ID
            assert json_data["status"] == "UPLOADED"
    finally:
        remove_dummy_image()

def test_upload_deduplication(test_client):
    """TC_BACKEND_01: Verify Upload Deduplication (Idempotency)"""
    # Re-upload the SAME ID. This simulates a retry after network failure.
    create_dummy_image()
    try:
        with open(TEST_IMAGE_PATH, "rb") as f:
            files = {"file": ("test_image.jpg", f, "image/jpeg")}
            data = {"media_id": TEST_MEDIA_ID} # SAME ID as above
            
            response = test_client.post("/api/upload-media", files=files, data=data)
            
            # Should be 200 OK (not error), but message should indicate deduplication
            assert response.status_code == 200
            json_data = response.json()
            assert "already exists" in json_data["message"]
            assert json_data["media_id"] == TEST_MEDIA_ID
    finally:
        remove_dummy_image()

def test_history_retrieval(test_client):
    """TC_HISTORY_01: Verify History Endpoint returns the uploaded item"""
    response = test_client.get("/api/history")
    assert response.status_code == 200
    
    history = response.json()
    assert isinstance(history, list)
    assert len(history) > 0
    
    # Check if our uploaded item is in the list
    found = False
    for item in history:
        if item["media_id"] == TEST_MEDIA_ID:
            found = True
            assert "file_path" in item
            # Verify basic structure
            assert item["status"] in ["UPLOADED", "PROCESSING", "COMPLETED"]
            break
            
    assert found, f"Uploaded media {TEST_MEDIA_ID} not found in history"

def test_static_file_serving(test_client):
    """TC_BACKEND_02: Verify Static File Access"""
    # First get the filename from history
    response = test_client.get("/api/history")
    history = response.json()
    target_file = None
    
    for item in history:
        if item["media_id"] == TEST_MEDIA_ID:
            target_file = item["file_path"]
            break
            
    assert target_file is not None
    
    # Try to download the file directly
    file_url = f"/uploads/{target_file}"
    response = test_client.get(file_url)
    
    assert response.status_code == 200
    assert response.headers["content-type"] in ["image/jpeg", "image/png"]
