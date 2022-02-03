class CreateUsers < ActiveRecord::Migration[7.0]
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
      t.datetime :deleted_at
      t.datetime :joined_research_at

      t.string :github_username, null: true
      t.integer :reputation, null: false, default: 0

      t.json :roles, null: true

      t.text :bio, null: true
      t.string :avatar_url, null: true
      t.string :location, null: true
      t.string :pronouns, null: true

      t.integer :num_solutions_mentored, limit: 3, null: false, default: 0
      t.integer :mentor_satisfaction_percentage, limit: 1, null: true

      t.string :stripe_customer_id, null: true, index: {unique: true}
      t.integer :total_donated_in_cents, null: true, default: 0
      t.boolean :active_donation_subscription, null: true, default: false

      t.timestamps null: false

      t.index [:provider, :uid], unique: true
      t.index :github_username, unique: true
    end
  end
end
