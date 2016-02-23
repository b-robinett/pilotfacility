class AddTimetakenToDatapoints < ActiveRecord::Migration
  def change
    add_column :datapoints, :Time_Taken, :datetime
  end
end
