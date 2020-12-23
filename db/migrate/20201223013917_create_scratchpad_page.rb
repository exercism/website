class CreateScratchpadPage < ActiveRecord::Migration[6.1]
  def change
    create_table :scratchpad_pages do |t|
      t.belongs_to :about, polymorphic: true
      t.belongs_to :user, null: false, foreign_key: true
      t.text :content_markdown
      t.text :content_html
      t.string :uuid, null: false

      t.timestamps
    end
  end
end
