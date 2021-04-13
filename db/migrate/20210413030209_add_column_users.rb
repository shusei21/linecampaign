class AddColumnUsers < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :haircare_flag, :boolean, default: false, null: false
  	add_column :users, :skincare_flag, :boolean, default: false, null: false
  	add_column :users, :bodycare_flag, :boolean, default: false, null: false
  	add_column :users, :healthfood_flag, :boolean, default: false, null: false
  	add_column :users, :perfume_flag, :boolean, default: false, null: false
  	add_column :users, :alcohol_flag, :boolean, default: false, null: false
  end
end
