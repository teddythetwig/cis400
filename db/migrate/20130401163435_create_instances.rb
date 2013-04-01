class CreateInstances < ActiveRecord::Migration
  def change
    create_table :instances do |t|
      t.integer :server_id
      t.string :name

      t.timestamps
    end
  end
end
