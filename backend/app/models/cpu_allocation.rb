class CpuAllocation < ApplicationRecord
  validates :total_cores, :allocated_cores, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :reason, presence: true
end