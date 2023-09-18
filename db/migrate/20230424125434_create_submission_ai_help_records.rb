class CreateSubmissionAIHelpRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :submission_ai_help_records do |t|
      t.bigint :submission_id, null: false
      t.string :source, null: false
      t.text :advice_markdown, null: false
      t.text :advice_html, null: false

      t.timestamps

      t.foreign_key :submissions
    end
  end
end
