class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :handle, null: false
      t.string :name, null: false
      t.string :provider
      t.string :uid
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email
      t.datetime :accepted_privacy_policy_at
      t.datetime :accepted_terms_at

      t.string :github_username, null: true
      t.integer :reputation, null: false, default: 0

      t.text :bio, null: true

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token, unique: true
    add_index :users, [:provider, :uid], unique: true
    add_index :users, :handle, unique: true
  end
end
