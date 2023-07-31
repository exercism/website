class CreatePartners < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :partners do |t|
      t.string :name, null: false
      t.string :slug, null: false, index: { unique: true }
      t.text :headline, null: true
      t.text :support_markdown, null: true
      t.text :support_html, null: true
      t.text :description_markdown, null: false
      t.text :description_html, null: false
      t.string :website_url, null: false

      t.timestamps
    end
  end

  def down
    drop_table :partners
  end
end
