class CreateBootcampLevels < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :bootcamp_levels do |t|
      t.integer :idx, null: false

      t.string :title, null: false
      t.text :description, null: false
      t.text :content_markdown, null: false
      t.text :content_html, null: false
      
      t.timestamps
    end
  end
end
