class CreateSolutionComments < ActiveRecord::Migration[6.1]
  def change
    create_table :solution_comments do |t|
      t.belongs_to :solution, null: false, foreign_key: true
      t.belongs_to :author, null: false, foreign_key: {to_table: "users"}
      t.text :content_markdown, null: false
      t.text :content_html, null: false
      t.datetime :deleted_at, null: true

      t.timestamps
    end
  end
end
