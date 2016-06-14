class UpdateReactorVol < ActiveRecord::Migration
  def change
  	change_column :runs, :Reactor_vol, :float
  end
end
