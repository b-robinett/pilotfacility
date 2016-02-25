class ChangeReactorPos < ActiveRecord::Migration
  def change
  	change_column :runs, :Reactor_Pos, :string
  end
end
