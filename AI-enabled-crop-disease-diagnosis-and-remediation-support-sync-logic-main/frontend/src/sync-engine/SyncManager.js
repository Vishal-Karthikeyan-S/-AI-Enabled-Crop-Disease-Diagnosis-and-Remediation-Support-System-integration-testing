/**
 * Sync Manager Module
 * 
 * This module handles:
 * - Saving submissions to the offline queue
 * - Syncing queued submissions to the backend server
 * - Moving successfully synced items to history
 * 
 * It works seamlessly whether the user is online or offline.
 */

import { addToQueue, getQueue, clearQueueItem, addToHistory } from './db';
import { v4 as uuidv4 } from 'uuid';

// Backend API endpoint for syncing submissions
const BACKEND_URL = 'http://localhost:5000/api/sync';

/**
 * Save a new submission to the offline queue
 * 
 * This function:
 * - Generates a unique UUID for the submission
 * - Adds metadata (createdAt, status)
 * - Stores it in IndexedDB for offline persistence
 * 
 * @param {Object} data - The submission data (text, image, timestamp)
 * @returns {Promise<Object>} The created submission object with UUID
 */
export const saveSubmission = async (data) => {
    const submission = {
        id: uuidv4(),                              // Unique identifier
        data: data,                                // User's submission (text + image)
        createdAt: new Date().toISOString(),       // When it was created
        status: 'queued'                           // Status: queued, syncing, synced
    };
    await addToQueue(submission);
    return submission;
};

/**
 * Sync all queued submissions to the backend server
 * 
 * This function:
 * - Gets all pending items from the queue
 * - Sends them to the backend in a single POST request
 * - On success: moves items to history and removes from queue
 * - On failure: keeps items in queue for retry later
 * 
 * The backend handles deduplication, so it's safe to retry.
 * 
 * @returns {Promise<Object>} Object with count of synced items: { synced: number }
 * @throws {Error} If the sync fails (network error or server rejection)
 */
export const syncQueue = async () => {
    const queue = await getQueue();
    if (queue.length === 0) return { synced: 0 };

    console.log("Attempting to sync...", queue.length, "items");

    try {
        // Send all queued items to the backend
        const response = await fetch(BACKEND_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ submissions: queue })
        });

        if (response.ok) {
            // Success! Move items to history and clear from queue
            for (const item of queue) {
                await addToHistory(item);           // Add to history with sync timestamp
                await clearQueueItem(item.id);      // Remove from pending queue
            }
            return { synced: queue.length };
        } else {
            // Server rejected the sync (e.g., 400, 500 error)
            console.error("Sync failed", response.status);
            throw new Error("Server rejected sync");
        }
    } catch (error) {
        // Network error or other failure - items stay in queue
        console.error("Sync error:", error);
        throw error;
    }
};
