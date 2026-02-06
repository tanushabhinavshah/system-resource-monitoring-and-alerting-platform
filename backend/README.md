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
bin/rails db:seed   # 🚨 Critical for Thresholds and CPU cores
```

### 4. Running the Platform
Use our custom startup script. It automatically kills old processes and clears stale files for you:
```bash
./dev.sh
```

---

## 📡 API Documentation

### 1. Real-time Streams (SSE)

These endpoints stay open and "push" data to you.
- **Metrics Stream:** `GET /metrics/stream` (Event: `metric_update`)
- **Alerts Stream:** `GET /alerts/stream` (Event: `alert_event`)

### 2. Threshold Management
**Endpoint:** `resource :threshold`

- **GET `/threshold`**: Returns current alerting limits.
- **PATCH `/threshold`**: Updates limits.
  ```json
  {
    "cpu_threshold": 80.0,
    "memory_threshold": 90.0,
    "network_in_threshold": 1000.0,
    "network_out_threshold": 1000.0
  }
  ```

### 3. Spike Simulation
**Endpoint:** `POST /metrics/simulate-spike`
Use this to test the platform without crashing your machine.

**Body Format:**
```json
{
  "cpu_usage_percent": 99.5,
  "memory_usage_percent": 90.0,
  "duration_seconds": 20
}
```
*Note: This creates a "Simulation Lock" that pauses real metric collection for the specified duration.*

### 4. CPU Allocation / Auto-Scaling
**Endpoint:** `GET /cpu-allocation`

Returns the **latest** scaling entry from the history log.
```json
{
  "total_cores": 16,
  "allocated_cores": 2,
  "reason": "Scaling UP: CPU WARNING Alert (+1). Total cores: 2"
}
```
*Strategy: Frontend should hit this API whenever it receives a CPU alert in the Alert Stream.*

---

## 🧠 Key Backend Architecture Points
- **Automated Heartbeat:** The system starts collecting metrics automatically on server boot (via `config/initializers/monitoring.rb`).
- **SSE vs WebSockets:** We use SSE because it is more efficient for "Server-to-Browser" one-way dashboards. 
- **High Concurrency:** The server is configured with 20 threads to handle multiple frontend reloads safely.
- **Audit Logging:** Every scaling event is recorded as a new row in the database, not an update.

---

## 🛠 Troubleshooting
- **NoMethodError (nil for allocated_cores):** Ensure you have run `bin/rails db:seed` to initialize the first core.
- **Frontend not listening:** Make sure to stop any old `curl` or Postman streams.
- **Port already in use:** Our `./dev.sh` script fixes this by running `fuser -k 3000/tcp` before starting.
