class CreateCpuAllocations < ActiveRecord::Migration[8.1]
  def change
    create_table :cpu_allocations do |t|
      t.integer :total_cores
      t.integer :allocated_cores
      t.string :reason

      t.timestamps
    end
  end
end
