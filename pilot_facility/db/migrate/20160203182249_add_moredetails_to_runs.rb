class AddMoredetailsToRuns < ActiveRecord::Migration
  def change
    add_column :runs, :Parent_Run, :integer
    add_column :runs, :Day_Harvested, :integer
    add_column :runs, :Media_ID, :string
    remove_column :runs, :Start_DW
  end
end
