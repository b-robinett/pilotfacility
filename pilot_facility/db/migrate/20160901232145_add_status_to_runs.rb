class AddStatusToRuns < ActiveRecord::Migration
  def change
  	add_column :runs, :Status, :integer
  end
end
