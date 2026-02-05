#!/bin/bash

# --- Dev Startup Script ---
# Cleans up ghost processes and starts the monitoring server

echo "🧹 Cleaning up old Rails processes..."

# Kill any process on port 3000 (standard Rails port)
if command -v fuser > /dev/null; then
  fuser -k 3000/tcp 2>/dev/null
else
  lsof -ti:3000 | xargs kill -9 2>/dev/null
fi

# Remove the stale PID file
rm -f tmp/pids/server.pid

echo "🚀 Starting System Monitoring Backend..."

# Start the Rails server
bin/rails server
