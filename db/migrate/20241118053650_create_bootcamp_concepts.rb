class CreateBootcampConcepts < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :bootcamp_concepts do |t|
      t.string :slug, null: false

      t.bigint :parent_id, null: true
      t.integer :level_idx, null: false
      t.boolean :apex, null: false, default: false

      t.string :title, null: false
      t.text :description, null: false
      t.text :content_markdown, null: false
      t.text :content_html, null: false

      t.timestamps
      
      t.foreign_key :bootcamp_concepts, column: :parent_id
    end
  end
end
