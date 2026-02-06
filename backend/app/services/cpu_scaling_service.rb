class CpuScalingService
  def self.scale_up(severity)
    latest = CpuAllocation.last
    
    # Logic: Just add 1 core regardless if it's Warning or Critical.
    # If we go from Warning(+1) -> Critical(+1), that equals +2 total.
    new_count = latest.allocated_cores + 1
    
    # Safety: Don't try to allocate 17 cores if you only have 16.
    return if new_count > latest.total_cores

    CpuAllocation.create!(
      total_cores: latest.total_cores,
      allocated_cores: new_count,
      reason: "Scaling UP: CPU #{severity.upcase} Alert (+1). Total cores: #{new_count}"
    )
    puts "🔼 [AUTO-SCALE LOGGED]: Added 1 core."
  end

  def self.scale_down(from_severity)
    latest = CpuAllocation.last
    
    # If we are resolving a CRITICAL alert, we must remove 2 cores.
    # If it was just a WARNING, we only remove 1.
    decrement = (from_severity == "critical") ? 2 : 1
    
    # [.max] ensures that even if we subtract 2, we never hit 0 cores.
    new_count = [latest.allocated_cores - decrement, 1].max

    CpuAllocation.create!(
      total_cores: latest.total_cores,
      allocated_cores: new_count,
      reason: "Scaling DOWN: CPU #{from_severity} Resolved (-#{decrement}). Total cores: #{new_count}"
    )
    puts "🔽 [AUTO-SCALE LOGGED]: Released #{decrement} core(s)."
  end
end