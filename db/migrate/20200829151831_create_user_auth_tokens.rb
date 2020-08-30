class CreateUserAuthTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :user_auth_tokens do |t|
      t.belongs_to :user, foreign_key: true, null: false
      t.string :token, null: false, unique: true
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
