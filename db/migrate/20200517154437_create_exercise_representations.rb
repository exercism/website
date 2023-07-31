class CreateExerciseRepresentations < ActiveRecord::Migration[7.0]
  def change
    create_table :exercise_representations do |t|
      t.belongs_to :exercise, foreign_key: true, null: false
      t.belongs_to :source_submission, foreign_key: {to_table: :submissions }, null: false
      t.text :ast, null: false
      t.string :ast_digest, null: false
      t.text :mapping, null: true

      t.column :feedback_type, :tinyint, null: true
      t.text :feedback_markdown, null: true
      t.text :feedback_html, null: true
      t.belongs_to :feedback_author, foreign_key: { to_table: :users }, null: true
      t.belongs_to :feedback_editor, foreign_key: { to_table: :users }, null: true

      t.timestamps

      t.index %i[exercise_id ast_digest], unique: true, name: "exercise_representations_unique"
    end
  end
end
