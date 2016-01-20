class CreateDatapoints < ActiveRecord::Migration
  def change
    create_table :datapoints do |t|
      t.integer :Run_ID
      t.string :Var_Name
      t.string :Var_Metric
      t.float :Var_Value
      t.string :Submitter

      t.timestamps null: false
    end
  end
end
