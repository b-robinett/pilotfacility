class AddReactorvolToRuns < ActiveRecord::Migration
  def change
  	add_column :runs, :Reactor_vol, :integer
    add_column :runs, :Reactor_Pos, :integer
  end
end
