class CreatePartners < ActiveRecord::Migration[7.0]
  def change
    create_table :partners do |t|
      t.string :name, null: false
      t.string :slug, null: false, index: { unique: true }
      t.text :support_explanation, null: true
      t.text :description_markdown, null: false
      t.text :description_html, null: false

      t.timestamps
    end
  end
end
