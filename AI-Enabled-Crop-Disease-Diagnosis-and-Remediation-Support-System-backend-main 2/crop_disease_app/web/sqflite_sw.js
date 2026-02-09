importScripts("https://unpkg.com/sqlite3/sqlite3.js");

self.onmessage = function (event) {
    console.log("Worker received message:", event.data);
};