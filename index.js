const express = require('express');
const { requestLogger } = require('./logger');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(requestLogger);

// Mock user data
const mockUsers = [
  { id: 1, name: 'Alice Johnson', email: 'alice@example.com' },
  { id: 2, name: 'Bob Smith', email: 'bob@example.com' },
  { id: 3, name: 'Charlie Lee', email: 'charlie@example.com' },
];

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
  });
});

// Users endpoint (returns mock data)
app.get('/users', (req, res) => {
  res.status(200).json({
    count: mockUsers.length,
    users: mockUsers,
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Not Found' });
});

// Basic error handler
app.use((err, req, res, next) => {
  console.error(`[${new Date().toISOString()}] Error:`, err.stack || err.message);
  res.status(500).json({ error: 'Internal Server Error' });
});

// Only start listening when this file is run directly (e.g. `node index.js`).
// This lets test files `require('../index')` and use supertest against the
// app without also spinning up a real server on PORT.
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`[${new Date().toISOString()}] Server listening on http://localhost:${PORT}`);
  });
}

module.exports = app;
