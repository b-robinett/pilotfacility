class ChangeStrainId < ActiveRecord::Migration
  def change
  	change_column :runs, :Strain_ID, :text
  end
end
