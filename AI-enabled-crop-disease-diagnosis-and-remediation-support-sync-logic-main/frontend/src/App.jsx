/**
 * Main Application Component
 * 
 * This is the root component for the Crop Disease Diagnosis PWA.
 * 
 * Features:
 * - Offline-first architecture with IndexedDB
 * - Photo upload with preview
 * - Automatic sync when online
 * - Upload history with status tracking
 * - Database error recovery
 * 
 * State Management:
 * - isOnline: Tracks network connectivity
 * - queue: Pending uploads waiting to sync
 * - history: Successfully synced uploads
 * - formData: Text input from user
 * - selectedImage/imagePreview: Photo upload state
 * - syncStatus: Current sync operation status
 */

import { useState, useEffect } from 'react';
import './App.css';
import { saveSubmission, syncQueue } from './sync-engine/SyncManager';
import { getQueue, getHistory, resetDatabase } from './sync-engine/db';

function App() {
  // Network connectivity state
  const [isOnline, setIsOnline] = useState(navigator.onLine);

  // Data states
  const [queue, setQueue] = useState([]);              // Pending uploads
  const [history, setHistory] = useState([]);          // Synced uploads
  const [formData, setFormData] = useState('');        // Text input

  // Sync status for user feedback
  const [syncStatus, setSyncStatus] = useState('Idle');

  // Photo upload states
  const [selectedImage, setSelectedImage] = useState(null);      // File object
  const [imagePreview, setImagePreview] = useState(null);        // Base64 preview

  useEffect(() => {
    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    // Initial load of queue and history with error recovery
    const initializeApp = async () => {
      try {
        await refreshQueue();
        await refreshHistory();
      } catch (error) {
        console.error('Failed to initialize app:', error);
        // If initialization fails, automatically reset database
        console.log('Attempting automatic database recovery...');
        try {
          await resetDatabase();
          console.log('Database reset successfully. Retrying initialization...');
          await refreshQueue();
          await refreshHistory();
        } catch (resetError) {
          console.error('Database recovery failed:', resetError);
          alert('Database error detected. Please click the "Reset DB" button in the header to fix it.');
        }
      }
    };

    initializeApp();

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  /**
   * Auto-sync when device comes back online
   * 
   * This ensures that any pending uploads are automatically
   * synced as soon as the network connection is restored.
   */
  useEffect(() => {
    if (isOnline && queue.length > 0) {
      handleSync();
    }
  }, [isOnline]);

  /**
   * Load pending uploads from IndexedDB
   * 
   * Includes error handling to gracefully handle database issues.
   */
  const refreshQueue = async () => {
    try {
      const q = await getQueue();
      setQueue(q);
    } catch (error) {
      console.error('Error loading queue:', error);
      setQueue([]);
    }
  };

  /**
   * Load upload history from IndexedDB
   * 
   * Includes error handling to gracefully handle database issues.
   */
  const refreshHistory = async () => {
    try {
      const h = await getHistory();
      setHistory(h);
    } catch (error) {
      console.error('Error loading history:', error);
      setHistory([]);
    }
  };

  /**
   * Reset the database and reload the page
   * 
   * This is a manual fix for database corruption or upgrade issues.
   * Shows a confirmation dialog before proceeding.
   */
  const handleResetDatabase = async () => {
    if (confirm('This will clear all pending uploads and history. Continue?')) {
      await resetDatabase();
      alert('Database reset! Please refresh the page (F5).');
      window.location.reload();
    }
  };

  /**
   * Handle photo selection from file input
   * 
   * - Stores the File object
   * - Creates a base64 preview for display
   * - Base64 is also used for IndexedDB storage
   */
  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setSelectedImage(file);

      // Create preview
      const reader = new FileReader();
      reader.onloadend = () => {
        setImagePreview(reader.result);
      };
      reader.readAsDataURL(file);
    }
  };

  /**
   * Handle form submission
   * 
   * - Creates submission with text and image
   * - Saves to IndexedDB queue
   * - If online, immediately attempts to sync
   * - Shows error alert if submission fails
   */
  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData && !selectedImage) return;

    const submissionData = {
      text: formData,
      timestamp: Date.now(),
      image: imagePreview // base64 image data
    };

    try {
      await saveSubmission(submissionData);
      setFormData('');
      setSelectedImage(null);
      setImagePreview(null);
      await refreshQueue();

      // If online, try to sync immediately
      if (navigator.onLine) {
        handleSync();
      }
    } catch (error) {
      console.error('Submission failed:', error);
      alert('Failed to save submission. Try resetting the database using the button in the header.');
    }
  };

  /**
   * Manually trigger sync of pending uploads
   * 
   * - Sends all queued items to backend
   * - Updates sync status for user feedback
   * - Refreshes queue and history after sync
   */
  const handleSync = async () => {
    setSyncStatus('Syncing...');
    try {
      const result = await syncQueue();
      setSyncStatus(`Synced ${result.synced} items`);
      await refreshQueue();
      await refreshHistory();
      setTimeout(() => setSyncStatus('Idle'), 3000);
    } catch (e) {
      setSyncStatus('Sync Failed');
    }
  };

  // Combine pending and synced items for unified history display
  const allItems = [
    ...queue.map(item => ({ ...item, status: 'pending' })),
    ...history
  ];

  return (
    <div className={`app-container ${isOnline ? 'online' : 'offline'}`}>
      <header>
        <h1>🌾 Crop Disease Diagnosis</h1>
        <div className="header-controls">
          <div className="status-badge">
            {isOnline ? '🟢 ONLINE' : '🔴 OFFLINE'}
          </div>
          <button onClick={handleResetDatabase} className="reset-btn" title="Reset database if you're having issues">
            🔄 Reset DB
          </button>
        </div>
      </header>

      <main>
        <section className="input-section">
          <h2>New Submission</h2>
          <form onSubmit={handleSubmit}>
            <textarea
              value={formData}
              onChange={(e) => setFormData(e.target.value)}
              placeholder="Enter crop details or symptoms..."
            />

            <div className="photo-upload">
              <label htmlFor="photo-input" className="photo-label">
                📷 {selectedImage ? selectedImage.name : 'Add Photo'}
              </label>
              <input
                id="photo-input"
                type="file"
                accept="image/*"
                onChange={handleImageChange}
                className="photo-input"
              />
            </div>

            {imagePreview && (
              <div className="image-preview">
                <img src={imagePreview} alt="Preview" />
                <button
                  type="button"
                  onClick={() => {
                    setSelectedImage(null);
                    setImagePreview(null);
                  }}
                  className="remove-image"
                >
                  ✕ Remove
                </button>
              </div>
            )}

            <button type="submit" disabled={!formData && !selectedImage}>
              {isOnline ? '📤 Submit' : '💾 Save Offline'}
            </button>
          </form>
        </section>

        {queue.length > 0 && (
          <section className="queue-section">
            <div className="queue-header">
              <h2>⏳ Pending Uploads ({queue.length})</h2>
              <button onClick={handleSync} disabled={queue.length === 0 || !isOnline} className="sync-btn">
                Force Sync 🔄
              </button>
            </div>

            <div className="sync-status">Status: {syncStatus}</div>

            <div className="queue-list">
              {queue.map((item) => (
                <div key={item.id} className="queue-item">
                  <div className="queue-item-content">
                    {item.data.image && (
                      <img src={item.data.image} alt="Crop" className="queue-thumbnail" />
                    )}
                    <div className="queue-item-details">
                      <span className="id">ID: {item.id.slice(0, 8)}...</span>
                      <span className="data">{item.data.text || 'Photo only'}</span>
                    </div>
                  </div>
                  <span className="badge badge-pending">Pending</span>
                </div>
              ))}
            </div>
          </section>
        )}

        <section className="history-section">
          <h2>📋 Upload History ({allItems.length})</h2>

          <div className="history-list">
            {allItems.length === 0 && <p className="empty-msg">No uploads yet.</p>}
            {allItems.map((item) => (
              <div key={item.id} className="history-item">
                <div className="history-item-content">
                  {item.data.image && (
                    <img src={item.data.image} alt="Crop" className="history-thumbnail" />
                  )}
                  <div className="history-item-details">
                    <span className="id">📷 ID: {item.id}</span>
                    <span className="data">{item.data.text || 'Photo only'}</span>
                    <span className="timestamp">
                      {item.status === 'synced'
                        ? `✓ Synced: ${new Date(item.syncedAt).toLocaleString()}`
                        : `Created: ${new Date(item.createdAt).toLocaleString()}`
                      }
                    </span>
                  </div>
                </div>
                <span className={`badge ${item.status === 'synced' ? 'badge-synced' : 'badge-pending'}`}>
                  {item.status === 'synced' ? '✓ Synced' : '⏳ Pending'}
                </span>
              </div>
            ))}
          </div>
        </section>
      </main>
    </div>
  );
}

export default App;
