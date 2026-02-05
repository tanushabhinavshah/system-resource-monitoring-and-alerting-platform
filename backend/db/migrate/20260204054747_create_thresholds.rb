class CreateThresholds < ActiveRecord::Migration[8.1]
  def change
    create_table :thresholds do |t|
      t.float :cpu_threshold
      t.float :memory_threshold
      t.float :network_in_threshold
      t.float :network_out_threshold

      t.timestamps
    end
  end
end
