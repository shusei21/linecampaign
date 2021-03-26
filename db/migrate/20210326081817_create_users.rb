class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :user_id
      t.boolean :campaign_flag, default: false

      t.timestamps
    end
  end
end
