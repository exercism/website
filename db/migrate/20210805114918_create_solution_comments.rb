class CreateSolutionComments < ActiveRecord::Migration[7.0]
  def change
    create_table :solution_comments do |t|
      t.string :uuid, null: false, index: {unique: true}

      t.belongs_to :solution, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true
      t.text :content_markdown, null: false
      t.text :content_html, null: false
      t.datetime :deleted_at, null: true

      t.timestamps
    end
  end
end
