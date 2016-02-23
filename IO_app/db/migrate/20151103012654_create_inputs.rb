class CreateInputs < ActiveRecord::Migration
  def change
    create_table :inputs do |t|

      t.timestamps null: false
    end
  end
end
