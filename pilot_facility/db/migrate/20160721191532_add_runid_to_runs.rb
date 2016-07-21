class AddRunidToRuns < ActiveRecord::Migration
  def change
  	add_column :runs, :run_index, :integer
  end
end
