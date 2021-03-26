class AddAttrEncryptedToUsers < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :encrypted_user_id, :string
    add_column :users, :encrypted_user_id_iv, :string
  end
end
