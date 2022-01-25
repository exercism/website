class CreateScratchpadPages < ActiveRecord::Migration[7.0]
  def change
    create_table :scratchpad_pages do |t|
      t.belongs_to :about, polymorphic: true, null: false
      t.belongs_to :user, null: false, foreign_key: true
      t.text :content_markdown, null: false
      t.text :content_html, null: false

      t.timestamps
    end
  end
end
