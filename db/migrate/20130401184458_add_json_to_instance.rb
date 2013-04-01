class AddJsonToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :db_json, :text
    remove_column :servers, :db_json
  end
end
