class Alert < ApplicationRecord
  RESOURCE_TYPES = %w[cpu memory network_in network_out].freeze
  SEVERITIES = %w[warning critical].freeze

  validates :resource_type, inclusion: { in: RESOURCE_TYPES }
  validates :severity, inclusion: { in: SEVERITIES }
  validates :reason, :timestamp, presence: true
  validates :is_resolved, inclusion: { in: [true, false] }
end