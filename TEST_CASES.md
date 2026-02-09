# Test Case Specification
**Project:** AI-Enabled Crop Disease Diagnosis & Remediation Support System
**Module:** Integration (Frontend <-> Backend)
**Date:** 2026-02-09
**Tester:** Test Engineer

## 1. Authentication Module

| Test Case ID | TC_AUTH_01 |
| :--- | :--- |
| **Title** | Verify User Registration with Valid Data |
| **Pre-requisites** | Backend running (`localhost:8000`), Database clean. |
| **Test Steps** | 1. Open App.<br>2. Navigate to "Register".<br>3. Enter valid Name, Email (`test@test.com`), and Password.<br>4. Click "Sign Up". |
| **Expected Result** | User should be redirected to Dashboard using the new credentials. Backend should store user. |
| **Status** | ✅ **PASS** |

| Test Case ID | TC_AUTH_02 |
| :--- | :--- |
| **Title** | Verify Login with Invalid Credentials |
| **Test Steps** | 1. Navigate to "Login".<br>2. Enter correct Email but wrong Password.<br>3. Click "Login". |
| **Expected Result** | Error message "Invalid email or password" should be displayed. |
| **Status** | ✅ **PASS** |

| Test Case ID | TC_AUTH_03 |
| :--- | :--- |
| **Title** | Verify Guest Login Access |
| **Test Steps** | 1. On Landing Page, click "Continue as Guest". |
| **Expected Result** | Dashboard should load with restricted profile features but full diagnosis capability. |
| **Status** | ✅ **PASS** |

---

## 2. Core Feature: Diagnosis (Online)

| Test Case ID | TC_CORE_01 |
| :--- | :--- |
| **Title** | Verify Image Upload & Diagnosis (Online) |
| **Pre-requisites** | Device Online (`Wifi/4G`). Backend Running. |
| **Test Steps** | 1. Click "+" on Dashboard.<br>2. Select "Gallery" or "Camera".<br>3. Choose an image.<br>4. Submit for diagnosis. |
| **Expected Result** | Loading spinner appears. Image is uploaded to `/api/upload-media`. result page displays "Confidence" and "Disease Name". |
| **Status** | ✅ **PASS** |

---

## 3. Core Feature: Offline Protocol

| Test Case ID | TC_OFFLINE_01 |
| :--- | :--- |
| **Title** | Verify Local Queueing when Offline |
| **Pre-requisites** | **Constraint:** Internet Disconnected / Backend Stopped. |
| **Test Steps** | 1. Disconnect Network.<br>2. Perform Image Submission (as in TC_CORE_01).<br>3. Check UI Status. |
| **Expected Result** | App should NOT crash. Toast "Saved locally (Offline)" appears. Item appears in History as "Waiting for connection". |
| **Status** | ✅ **PASS** |

| Test Case ID | TC_OFFLINE_02 |
| :--- | :--- |
| **Title** | Verify Auto-Sync on Reconnection |
| **Pre-requisites** | Pending offline items exists (from TC_OFFLINE_01). |
| **Test Steps** | 1. Reconnect Network.<br>2. Observe App (do not interact). |
| **Expected Result** | `ConnectivityProvider` detects change. `SyncService` triggers. Status updates from "Saved" -> "Uploading" -> "Diagnosed". |
| **Status** | ✅ **PASS** |

---

## 4. Backend Integrity

| Test Case ID | TC_BACKEND_01 |
| :--- | :--- |
| **Title** | Verify Upload Deduplication |
| **Test Steps** | 1. Send an upload request with `media_id="test-uuid-1"`.<br>2. Send the SAME request again with `media_id="test-uuid-1"`. |
| **Expected Result** | First request returns `200/201 (Created)`. Second request returns `200 (OK)` with message "Media already exists". No duplicate file on disk. |
| **Status** | ✅ **PASS** |

| Test Case ID | TC_BACKEND_02 |
| :--- | :--- |
| **Title** | Verify Static File Serving |
| **Test Steps** | 1. Upload image `foo.jpg` via App.<br>2. Open Browser to `http://localhost:8000/uploads/foo.jpg`. |
| **Expected Result** | Image loads in browser correctly (200 OK). No 403 Forbidden or 404 Not Found. |
| **Status** | ✅ **PASS** |
