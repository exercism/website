class CreatePartnerPerks < ActiveRecord::Migration[7.0]
  def up
    create_table :partner_perks do |t|
      t.belongs_to :partner, foreign_key: true
      t.integer :status, null: false, default: 0, size: 1
      t.integer :audience, null: false, default: 0, size: 1
      t.integer :num_impressions, null: false, default:0
      t.integer :num_clicks, null: false, default:0

      t.string :url, null: false
      t.string :about_text, null: false
      t.string :offer_markdown, null: false
      t.string :offer_html, null: false
      t.string :button_text, null: false

      t.timestamps
    end

    perk = Partner.first.perks.create!(
      url: "#",
      about_text: "Packt is the online library and learning platform for professional developers. Learn Python, JavaScript, Angular and more with eBooks, videos and courses.",
      offer_markdown: "Get **50% off a Packt annual membership** with your Exercism account.",
      button_text: "Claim 50% discount"
    )
    perk.logo.attach(io: File.open(Rails.root.join('app', 'images', 'partners', 'config-cat.png')), filename: "config-cat.png")
  end

  def down
    drop_table :partner_perks
  end
end
