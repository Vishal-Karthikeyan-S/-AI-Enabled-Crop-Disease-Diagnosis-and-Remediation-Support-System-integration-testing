/**
 * IndexedDB Database Module
 * 
 * This module manages the offline-first database for the crop disease diagnosis app.
 * It uses IndexedDB to store:
 * - Pending uploads (offline-queue): Items waiting to be synced to the server
 * - Upload history (upload-history): Successfully synced items with timestamps
 * 
 * The database automatically handles version upgrades and connection blocking issues.
 */

import { openDB, deleteDB } from 'idb';

// Database configuration constants
const DB_NAME = 'farmer-app-db';           // Name of the IndexedDB database
const QUEUE_STORE = 'offline-queue';       // Store for pending uploads
const HISTORY_STORE = 'upload-history';    // Store for synced items

// Singleton database instance to avoid multiple connections
let dbInstance = null;

/**
 * Initialize the IndexedDB database
 * 
 * This function:
 * - Creates the database if it doesn't exist
 * - Upgrades the database schema if needed (version 1 -> 2)
 * - Handles blocked connections from other tabs
 * - Automatically retries with database reset on failure
 * 
 * @returns {Promise<IDBDatabase>} The database instance
 */
export const initDB = async () => {
  // Return existing instance if already initialized
  if (dbInstance) return dbInstance;

  try {
    dbInstance = await openDB(DB_NAME, 2, {
      upgrade(db, oldVersion, newVersion, transaction) {
        console.log(`Upgrading database from version ${oldVersion} to ${newVersion}`);

        // Create queue store
        if (!db.objectStoreNames.contains(QUEUE_STORE)) {
          db.createObjectStore(QUEUE_STORE, { keyPath: 'id' });
          console.log('Created queue store');
        }

        // Create history store
        if (!db.objectStoreNames.contains(HISTORY_STORE)) {
          const historyStore = db.createObjectStore(HISTORY_STORE, { keyPath: 'id' });
          historyStore.createIndex('syncedAt', 'syncedAt');
          console.log('Created history store');
        }
      },
      blocked() {
        console.warn('⚠️ Database upgrade blocked by another connection');
        console.warn('Please close all other tabs with this app and refresh this page');
        alert('Database upgrade blocked!\n\nPlease:\n1. Close ALL other tabs with this app\n2. Refresh this page (F5)\n\nIf that doesn\'t work, click the "Reset DB" button.');
      },
      blocking() {
        console.warn('This connection is blocking a database upgrade');
        // Close this connection to allow upgrade
        if (dbInstance) {
          dbInstance.close();
          dbInstance = null;
        }
      },
    });
    return dbInstance;
  } catch (error) {
    console.error('Database initialization failed:', error);

    // If it's a blocking error, force reset
    if (error.message && error.message.includes('blocking')) {
      console.log('Forcing database reset due to blocking error...');
      await forceResetDatabase();
      // Try one more time after reset
      dbInstance = await openDB(DB_NAME, 2, {
        upgrade(db) {
          if (!db.objectStoreNames.contains(QUEUE_STORE)) {
            db.createObjectStore(QUEUE_STORE, { keyPath: 'id' });
          }
          if (!db.objectStoreNames.contains(HISTORY_STORE)) {
            const historyStore = db.createObjectStore(HISTORY_STORE, { keyPath: 'id' });
            historyStore.createIndex('syncedAt', 'syncedAt');
          }
        },
      });
      return dbInstance;
    }

    throw error;
  }
};

/**
 * Reset the database by deleting it completely
 * 
 * Use this when:
 * - Database is corrupted
 * - Schema upgrade fails
 * - User wants to clear all data
 * 
 * @returns {Promise<boolean>} True if reset successful, false otherwise
 */
export const resetDatabase = async () => {
  try {
    dbInstance = null;
    await deleteDB(DB_NAME);
    console.log('Database reset successfully');
    return true;
  } catch (error) {
    console.error('Failed to reset database:', error);
    return false;
  }
};

/**
 * Force reset the database with connection cleanup
 * 
 * More aggressive than resetDatabase():
 * - Closes all connections first
 * - Waits for connections to close
 * - Then deletes the database
 * 
 * @returns {Promise<boolean>} True if reset successful, false otherwise
 */
export const forceResetDatabase = async () => {
  try {
    // Close any existing connection
    if (dbInstance) {
      dbInstance.close();
      dbInstance = null;
    }

    // Wait a bit for connections to close
    await new Promise(resolve => setTimeout(resolve, 100));

    // Delete the database
    await deleteDB(DB_NAME);
    console.log('✅ Database forcefully reset');
    return true;
  } catch (error) {
    console.error('Failed to force reset database:', error);
    return false;
  }
};

/**
 * Add a submission to the offline queue
 * 
 * @param {Object} submission - The submission object with id, data, createdAt
 */
export const addToQueue = async (submission) => {
  const db = await initDB();
  await db.put(QUEUE_STORE, submission);
};

/**
 * Get all pending submissions from the queue
 * 
 * @returns {Promise<Array>} Array of pending submissions
 */
export const getQueue = async () => {
  const db = await initDB();
  return db.getAll(QUEUE_STORE);
};

/**
 * Remove a specific item from the queue by ID
 * 
 * @param {string} id - The UUID of the item to remove
 */
export const clearQueueItem = async (id) => {
  const db = await initDB();
  await db.delete(QUEUE_STORE, id);
}

/**
 * Clear all items from the queue
 */
export const clearQueue = async () => {
  const db = await initDB();
  await db.clear(QUEUE_STORE);
}

// ============ History Functions ============

/**
 * Add a successfully synced item to the history
 * 
 * This is called after an item is successfully uploaded to the server.
 * It adds sync metadata (status, timestamp) to the item.
 * 
 * @param {Object} item - The synced item from the queue
 */
export const addToHistory = async (item) => {
  const db = await initDB();
  const historyItem = {
    ...item,
    status: 'synced',
    syncedAt: new Date().toISOString()
  };
  await db.put(HISTORY_STORE, historyItem);
};

/**
 * Get all items from the upload history
 * 
 * @returns {Promise<Array>} Array of synced items, newest first
 */
export const getHistory = async () => {
  const db = await initDB();
  const items = await db.getAll(HISTORY_STORE);
  // Return in reverse chronological order (newest first)
  return items.reverse();
};

/**
 * Clear all items from the history
 */
export const clearHistory = async () => {
  const db = await initDB();
  await db.clear(HISTORY_STORE);
};
