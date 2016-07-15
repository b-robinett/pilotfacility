class AddLightnotesToRuns < ActiveRecord::Migration
  def change
  	add_column :runs, :Lightnotes, :string
  end
end
