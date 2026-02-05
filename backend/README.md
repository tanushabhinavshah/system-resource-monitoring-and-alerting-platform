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

### 2. Setup
```bash
cd backend
bundle install
bin/rails db:prepare
```

### 3. Running the Platform
You only need ONE terminal command to start everything (Web Server + Metric Worker):
```bash
bin/rails server
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
- **Threading:** The server uses multiple threads. It can handle up to 5 concurrent stream connections by default in development.

---

## 🛠 Troubleshooting
- **"Server already running":** Run `kill -9 $(cat tmp/pids/server.pid)` or `rm tmp/pids/server.pid`.
- **No data in stream:** Ensure the `MetricCollectorJob` is enqueued (check your terminal logs).
