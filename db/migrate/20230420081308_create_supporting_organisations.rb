class CreateSupportingOrganisations < ActiveRecord::Migration[7.0]
  def change
    create_table :supporting_organisations do |t|
      t.string :name, null: false
      t.string :slug, null: false, index: { unique: true }
      t.text :support_explanation, null: true
      t.text :description_markdown, null: false
      t.text :description_html, null: false
      t.text :insiders_offer_description, null: true
      t.boolean :featured, default: false, null: false
      t.boolean :has_insiders_offer, default: false, null: false

      t.timestamps
    end
  end
end
