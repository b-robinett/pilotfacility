class AddNotesToDatapoints < ActiveRecord::Migration
  def change
    add_column :datapoints, :Notes, :string
    add_column :datapoints, :Hrs_Post_Start, :integer
  end
end
