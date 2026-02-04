class Threshold < ApplicationRecord
  validates :cpu_threshold, :memory_threshold, :network_in_threshold, presence: true, numericality: { greater_than: 0, less_than: 100 }
  validates :network_out_threshold, presence: true, numericality: { greater_than: 0 }
end