class CreateAdverts < ActiveRecord::Migration[7.0]
  def up
    return if Rails.env.production?

    create_table :partner_adverts do |t|
      t.string :uuid, null: false

      t.belongs_to :partner, foreign_key: true
      t.integer :status, null: false, default: 0, size: 1
      t.integer :num_impressions, null: false, default:0 
      t.integer :num_clicks, null: false, default:0 

      t.string :url, null: false
      t.string :base_text, null: false
      t.string :emphasised_text, null: false

      t.timestamps
    end

    advert = Partner.first.adverts.create!(
      url: "#",
      base_text: "Cross-platform, developer-centric feature flags.",
      emphasised_text: "Get 20% off through Exercism Perks."
    )
    advert.logo.attach(io: File.open(Rails.root.join('app', 'images', 'partners', 'config-cat.png')), filename: "config-cat.png")
  end

  def down
    drop_table :partner_adverts
  end
end
