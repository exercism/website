class CreateProblemReports < ActiveRecord::Migration[7.0]
  def change
    create_table :problem_reports do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :track, null: true, foreign_key: true
      t.belongs_to :exercise, null: true, foreign_key: true
      t.belongs_to :about, polymorphic: true, null: true

      t.column :type, :tinyint, null: false, default: 0

      t.text :content_markdown, null: false
      t.text :content_html, null: false

      t.timestamps
    end
  end
end
