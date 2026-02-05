require 'sys/cpu'
require 'sys/memory'

class MetricCollectorService
  def self.collect
    new.collect
  end

  def collect
    # 1. Capture Network State BEFORE the wait
    start_net = parse_network_stats
    
    # 2. Wait exactly 1 second
    sleep 1

    # 3. Capture Network State AFTER the wait
    end_net = parse_network_stats

    # 4. Calculate the Delta (Difference)
    # This gives us the real KB/s because we waited exactly 1 second.
    network_in_rate = end_net[:in] - start_net[:in]
    network_out_rate = end_net[:out] - start_net[:out]

    # 5. Get CPU and Memory (These are already percentages, so no delta needed)
    cpu_usage = Sys::CPU.load_avg.first * 10 
    memory = Sys::Memory.memory
    total_mem = memory["MemTotal"].to_f
    available_mem = memory["MemAvailable"].to_f
    memory_usage = total_mem > 0 ? ((total_mem - available_mem) / total_mem) * 100 : 0
    
    metric_params = {
      cpu_usage_percent: cpu_usage.to_f.round(2),
      memory_usage_percent: memory_usage.to_f.round(2),
      network_in_kb: network_in_rate.to_f.round(2),
      network_out_kb: network_out_rate.to_f.round(2)
    }

    # Pass it to our Ingestion Manager
    IngestMetricService.new(metric_params).execute
  end

  private

  def parse_network_stats
    lines = File.readlines("/proc/net/dev")
    
    # We look for the first interface that has transferred > 0 bytes 
    # and is NOT 'lo' (loopback)
    stats_line = lines.find do |line|
      next if line =~ /lo:/ # Skip loopback
      
      # Extract the 'bytes received' column
      bytes_received = line.split(":")[1]&.split&.first.to_i
      bytes_received > 0
    end
    
    if stats_line
      parts = stats_line.split(":")
      data = parts[1].split
      # data[0] = Received Bytes, data[8] = Transmitted Bytes
      {
        in: data[0].to_f / 1024,
        out: data[8].to_f / 1024
      }
    else
      { in: 0, out: 0 }
    end
  end
end