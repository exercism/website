class AddAstDigestIndexToExerciseRepresentations < ActiveRecord::Migration[7.0]
  def change
    add_index :exercise_representations, %i[exercise_id ast_digest], unique: false, if_not_exists: true
  end
end
