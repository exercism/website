class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :handle, null: false, index: {unique: true}
      t.string :name, null: false
      t.string :provider
      t.string :uid
      t.string :email, null: false, default: "", index: {unique: true}
      t.string :encrypted_password, null: false, default: ""
      t.string :reset_password_token, index: {unique: true}
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.string :confirmation_token, index: {unique: true}
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email
      t.datetime :accepted_privacy_policy_at
      t.datetime :accepted_terms_at
      t.datetime :became_mentor_at

      t.string :github_username, null: true
      t.integer :reputation, null: false, default: 0

      t.json :roles, null: true

      t.text :bio, null: true
      t.string :avatar_url, null: true
      t.string :location, null: true
      t.string :pronouns, null: true

      t.timestamps null: false

      t.index [:provider, :uid], unique: true
    end
  end
end
