class AddJsonStringToServer < ActiveRecord::Migration
  def change
    add_column :servers, :db_json, :text
  end
end
