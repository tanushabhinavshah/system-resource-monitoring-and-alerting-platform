# 🚀 System Resource Monitoring & Alerting Platform (Backend)

Welcome! This is the core engine of the Monitoring Platform. It handles real-time metric collection from the host machine, evaluates thresholds, and streams data live to the frontend using Server-Sent Events (SSE).

---

## 🛠 Tech Stack
- **Framework:** Rails 8.1 (API-only)
- **Database:** PostgreSQL
- **Real-time:** SSE (ActionController::Live)
- **Background Jobs:** ActiveJob (Async Adapter - Single Process)
- **Metrics Source:** Linux `/proc` filesystem

---

## 🚦 Getting Started

### 1. Prerequisites
- Ruby 3.4+
- PostgreSQL installed and running
- Linux / WSL2 (required for metric collection logic)

### 2. Database Permissions (Run this FIRST)
Run this command to allow your computer to talk to the database without a password:
```bash
sudo -u postgres createuser -s $(whoami)
```

### 3. App Setup
```bash
cd backend
bundle install
bin/rails db:prepare
```

### 4. Running the Platform
Use our custom startup script. It automatically kills old processes and clears stale files for you:
```bash
./dev.sh
```

---

## 📡 API Documentation (Real-time Streams)

These endpoints stay open and "push" data to you as soon as it is available.

### 1. Metrics Stream
**Endpoint:** `GET /metrics/stream`
**Event Name:** `metric_update`
**Frequency:** Every ~6-7 seconds

**Response Format:**
```json
{
  "timestamp": "2026-02-05T14:10:00Z",
  "cpu_usage_percent": 12.5,
  "memory_usage_percent": 64.2,
  "network_in_kb": 150.2,
  "network_out_kb": 22.1
}
```

### 2. Alerts Stream
**Endpoint:** `GET /alerts/stream`
**Event Name:** `alert_event`
**Frequency:** Only when usage crosses thresholds.

**Ping Event:** On connection, it sends a `ping` event to confirm connectivity.
```json
{ "message": "Alert stream connected" }
```

**Alert Data Format:**
```json
{
  "resource_type": "cpu",
  "severity": "critical",
  "is_resolved": false,
  "reason": "Cpu usage reached 85.0% (Threshold: 75.0%)",
  "event_at": "2026-02-05T14:15:00Z"
}
```

---

## 🧠 Key Backend Architecture Points
- **Automated Heartbeat:** The system starts collecting metrics automatically on server boot (via `config/initializers/monitoring.rb`).
- **SSE vs WebSockets:** We use SSE because it is more efficient for "Server-to-Browser" one-way dashboards. 
- **High Concurrency:** The server is configured with 20 threads to handle multiple frontend reloads safely.

---

## 🛠 Troubleshooting
- **Frontend not listening:** Make sure to stop any old `curl` or Postman streams.
- **Port already in use:** Our `./dev.sh` script fixes this by running `fuser -k 3000/tcp` before starting.
