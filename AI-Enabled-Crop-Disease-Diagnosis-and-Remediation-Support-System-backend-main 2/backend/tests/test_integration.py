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

def test_user_isolation(test_client):
    """TC_ISOLATION_01: Verify User Data Separation"""
    # 1. Create two distinct users
    user1_id = str(uuid.uuid4())
    user2_id = str(uuid.uuid4())
    
    media1_id = str(uuid.uuid4())
    media2_id = str(uuid.uuid4())
    
    create_dummy_image()
    try:
        with open(TEST_IMAGE_PATH, "rb") as f:
            # Re-open file for second upload or just read bytes
            file_bytes = f.read()
            
        # 2. Upload for User 1
        test_client.post(
            "/api/upload-media", 
            files={"file": ("img1.jpg", file_bytes, "image/jpeg")},
            data={"media_id": media1_id, "user_id": user1_id}
        )
        
        # 3. Upload for User 2
        test_client.post(
            "/api/upload-media", 
            files={"file": ("img2.jpg", file_bytes, "image/jpeg")},
            data={"media_id": media2_id, "user_id": user2_id}
        )
        
        # 4. Fetch History for User 1
        resp1 = test_client.get(f"/api/history?user_id={user1_id}")
        history1 = resp1.json()
        ids1 = [item['media_id'] for item in history1]
        
        assert media1_id in ids1, "User 1 should see their own upload"
        assert media2_id not in ids1, "User 1 should NOT see User 2's upload"
        
        # 5. Fetch History for User 2
        resp2 = test_client.get(f"/api/history?user_id={user2_id}")
        history2 = resp2.json()
        ids2 = [item['media_id'] for item in history2]
        
        assert media2_id in ids2, "User 2 should see their own upload"
        assert media1_id not in ids2, "User 2 should NOT see User 1's upload"
        
    finally:
        remove_dummy_image()
