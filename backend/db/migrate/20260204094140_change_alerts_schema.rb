class ChangeAlertsSchema < ActiveRecord::Migration[8.1]
  def change
    remove_column :alerts, :event_type, :string
    add_column :alerts, :is_resolved, :boolean, default: false, null: false
  end
end