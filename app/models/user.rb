class User < ApplicationRecord
	attr_encrypted :user_id, key: 'This is a key that is 256 bits!!'
end
