class CreateMetrics < ActiveRecord::Migration[8.1]
  def change
    create_table :metrics do |t|
      t.float :cpu_usage_percent
      t.float :memory_usage_percent
      t.float :network_in_kb
      t.float :network_out_kb

      t.timestamps
    end
  end
end
