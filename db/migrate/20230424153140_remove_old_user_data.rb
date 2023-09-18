class RemoveOldUserData < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    remove_column :users, :bio
    remove_column :users, :roles
    remove_column :users, :insiders_status
    remove_column :users, :stripe_customer_id
    remove_column :users, :discord_uid
    remove_column :users, :accepted_privacy_policy_at
    remove_column :users, :accepted_terms_at
    remove_column :users, :became_mentor_at
    remove_column :users, :joined_research_at
    remove_column :users, :first_donated_at
    remove_column :users, :last_visited_on
    remove_column :users, :num_solutions_mentored
    remove_column :users, :mentor_satisfaction_percentage
    remove_column :users, :total_donated_in_cents
    remove_column :users, :active_donation_subscription
    remove_column :users, :show_on_supporters_page
    remove_column :users, :github_username
    remove_column :users, :paypal_payer_id
    remove_column :users, :usages
  end
end
