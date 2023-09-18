class DeprecatePremium < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    rename_column :partner_perks, :premium_url, :insiders_url
    rename_column :partner_perks, :premium_offer_summary_markdown, :insiders_offer_summary_markdown
    rename_column :partner_perks, :premium_offer_summary_html, :insiders_offer_summary_html
    rename_column :partner_perks, :premium_button_text, :insiders_button_text
    rename_column :partner_perks, :premium_offer_details, :insiders_offer_details
    rename_column :partner_perks, :premium_voucher_code, :insiders_voucher_code

    change_column_null :donations_payments, :product, true
    change_column_null :donations_subscriptions, :product, true

    User.where(flair: 4).update_all(flair: :insider)

    # Do these post-deploy
    remove_column :user_data, :active_donation_subscription
    remove_column :user_communication_preferences, :email_about_premium
  end
end
