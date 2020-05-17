class CreateExerciseRepresentations < ActiveRecord::Migration[6.0]
  def change
    create_table :exercise_representations do |t|
      t.belongs_to :exercise, foreign_key: true, null: false
      t.integer :exercise_version, null: false, limit: 2
      t.text :representation, null: false
      t.text :feedback_markdown, null: true
      t.text :feedback_html, null: true

      t.timestamps
    end
  end
end
