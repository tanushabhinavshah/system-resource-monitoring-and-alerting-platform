class CreateAlerts < ActiveRecord::Migration[8.1]
  def change
    create_table :alerts do |t|
      t.string :resource_type
      t.string :severity
      t.string :event_type
      t.text :reason
      t.datetime :timestamp

      t.timestamps
    end
  end
end
