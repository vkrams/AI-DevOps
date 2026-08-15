# Express App

A simple Node.js Express API.

## Endpoints

- `GET /health` — returns service health status and uptime.
- `GET /users` — returns a mock list of users.

## Setup

```bash
npm install
npm start
```

The server runs on `http://localhost:3000` by default (set `PORT` to change it).

## Logging

Every request is logged to the console with timestamp, method, path, status code, and response time.
