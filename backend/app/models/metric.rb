class Metric < ApplicationRecord
  # Validations
  validates :cpu_usage_percent, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :memory_usage_percent, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :network_in_kb, numericality: { greater_than_or_equal_to: 0 }
  validates :network_out_kb, numericality: { greater_than_or_equal_to: 0 }
  
  # Ensure all fields are present
  validates :cpu_usage_percent, :memory_usage_percent, :network_in_kb, :network_out_kb, presence: true
end