class CreateRuns < ActiveRecord::Migration
  def change
    create_table :runs do |t|
      t.string :Reactor_Type
      t.integer :Reactor_ID
      t.string :Scientist
      t.datetime :Approved_start_date
      t.datetime :Actual_start_date
      t.datetime :Actual_end_date
      t.string :Media
      t.float :pH
      t.float :Light_Intensity
      t.float :Light_Path
      t.integer :Temperature
      t.string :Organism
      t.integer :Strain_ID

      t.timestamps null: false
    end
  end
end
