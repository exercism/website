class CreatePartnerPerks < ActiveRecord::Migration[7.0]
  def up
    return if Rails.env.production?

    create_table :partner_perks do |t|
      t.string :uuid, null: false

      t.belongs_to :partner, foreign_key: true
      t.integer :status, null: false, default: 0, size: 1
      t.integer :num_clicks, null: false, default:0

      t.string :preview_text, null: false

      t.string :general_url, null: false
      t.string :general_offer_summary_markdown, null: false
      t.string :general_offer_summary_html, null: false
      t.string :general_button_text, null: false
      t.string :general_offer_details, null: false
      t.string :general_voucher_code

      t.string :premium_url
      t.string :premium_offer_summary_markdown
      t.string :premium_offer_summary_html
      t.string :premium_button_text
      t.string :premium_offer_details
      t.string :premium_voucher_code

      t.timestamps
    end
 end

  def down
    drop_table :partner_perks
  end
end
