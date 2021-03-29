class User < ApplicationRecord
	attr_encrypted :user_id, key: 'This is a key that is 256 bits!!'
	blind_index :user_id, key: Rails.application.credentials.blind_index_master_key
	validates :user_id, uniqueness: true
end
