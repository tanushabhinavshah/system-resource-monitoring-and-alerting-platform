# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
require 'etc'

puts "Seeding default thresholds..."

Threshold.find_or_create_by!(id: 1) do |t|
  t.cpu_threshold = 75.0
  t.memory_threshold = 80.0
  t.network_in_threshold = 1000.0
  t.network_out_threshold = 1000.0
end

puts "✅ Default thresholds established!"

CpuAllocation.find_or_create_by!(id: 1) do |c|
  c.total_cores = Etc.nprocessors # This detects your cores
  c.allocated_cores = 1           # Start with just one
  c.reason = "System initialized"
end