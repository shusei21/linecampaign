class AddUseridbidxToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :user_id_bidx, :string
    add_index :users, :user_id_bidx,  unique: true
  end
end
