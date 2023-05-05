class CreateUserData < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :user_data do |t|
      t.bigint :user_id, null: false

      t.text "bio"
      t.json "roles"
      t.json "usages"
      t.integer "insiders_status", limit: 1, default: 0, null: false

      t.string "github_username"
      t.string "stripe_customer_id"
      t.string "paypal_payer_id"
      t.string "discord_uid"

      t.datetime "accepted_privacy_policy_at"
      t.datetime "accepted_terms_at"
      t.datetime "became_mentor_at"
      t.datetime "joined_research_at"
      t.datetime "first_donated_at"
      t.date "last_visited_on"

      t.integer "num_solutions_mentored", limit: 3, default: 0, null: false
      t.integer "mentor_satisfaction_percentage", limit: 1
      t.integer "total_donated_in_cents", default: 0

      t.boolean "active_donation_subscription", default: false
      t.boolean "show_on_supporters_page", default: true, null: false

      t.timestamps

      t.index :user_id, unique: true

      t.index ["github_username"], name: "index_user_data_on_github_username", unique: true
      t.index ["insiders_status"], name: "index_user_data_on_insiders_status"
      t.index ["last_visited_on"], name: "index_user_data_on_last_visited_on"
      t.index ["stripe_customer_id"], name: "index_user_data_on_stripe_customer_id", unique: true
      t.index ["paypal_payer_id"], name: "index_user_data_on_paypal_payer_id", unique: true
      t.index ["discord_uid"], name: "index_user_data_on_discord_uid", unique: true
      t.index %w[first_donated_at show_on_supporters_page], name: "user-data-supporters-page", order: { first_donated_at: :desc }
    end
  end
end
