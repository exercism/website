class CreatePartnerPerks < ActiveRecord::Migration[7.0]
  def up
    return if Rails.env.production?

    create_table :partner_perks do |t|
      t.string :uuid, null: false

      t.belongs_to :partner, foreign_key: true
      t.integer :status, null: false, default: 0, size: 1
      t.integer :num_clicks, null: false, default:0

      t.string :preview_text, null: false
      t.string :offer_details, null: false

      t.string :general_url, null: false
      t.string :general_offer_markdown, null: false
      t.string :general_offer_html, null: false
      t.string :general_button_text, null: false

      t.string :premium_url
      t.string :premium_offer_markdown
      t.string :premium_offer_html
      t.string :premium_button_text

      t.timestamps
    end
 end

  def down
    drop_table :partner_perks
  end
end
