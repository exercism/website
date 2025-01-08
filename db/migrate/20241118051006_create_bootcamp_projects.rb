class CreateBootcampProjects < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :bootcamp_projects do |t|
      t.string :slug, null: false
      t.string :title, null: false
      t.text :description, null: false
      t.text :introduction_markdown, null: false
      t.text :introduction_html, null: false

      t.timestamps
    end
  end
end
