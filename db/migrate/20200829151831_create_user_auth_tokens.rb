class CreateUserAuthTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :user_auth_tokens do |t|
      t.belongs_to :user, foreign_key: true, null: false
      t.string :token, null: false, index: {unique: true}
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
