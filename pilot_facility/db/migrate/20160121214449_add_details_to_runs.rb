class AddDetailsToRuns < ActiveRecord::Migration
  def change
    add_column :runs, :CO2_Flow, :float
    add_column :runs, :Air_Flow, :float
    add_column :runs, :Depth, :float
    add_column :runs, :Start_OD, :float
    add_column :runs, :Start_DW, :float
    remove_column :runs, :Approved_start_date
  end
end
