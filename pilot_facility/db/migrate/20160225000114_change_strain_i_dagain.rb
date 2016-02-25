class ChangeStrainIDagain < ActiveRecord::Migration
  def change
  	change_column :runs, :Strain_ID, :string
  	change_column :datapoints, :Notes, :text
  end
end
