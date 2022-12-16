class AddVersionToExerciseRepresentations < ActiveRecord::Migration[7.0]
  def change
    unless Rails.env.production?
      add_column :exercise_representations, :representer_version, :smallint, null: false, default: 1
      add_column :exercise_representations, :exercise_version, :smallint, null: false, default: 1

      add_column :exercise_representations, :draft_feedback_type, :tinyint, null: true
      add_column :exercise_representations, :draft_feedback_markdown, :text, null: true

      add_index :exercise_representations,  [:exercise_id, :ast_digest, :representer_version, :exercise_version], name: "exercise_representations_guard", unique: true
      remove_index :exercise_representations, name: "exercise_representations_unique"
      remove_index :exercise_representations, name: "index_exercise_representations_on_exercise_id_and_ast_digest"
      remove_index :exercise_representations, name: "index_exercise_representations_on_exercise_id"
    end
  end
end
