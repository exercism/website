class AddExtraKeyForRepresenations < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :exercise_representations, :exercise_id_and_ast_digest_idx_cache, :string, null: true
    add_column :submission_representations, :exercise_id_and_ast_digest_idx_cache, :string, null: true

    add_index :exercise_representations, [:exercise_id_and_ast_digest_idx_cache, :id], order: {id: :desc}, name: "index_sub_rep"
    add_index :submission_representations, :exercise_id_and_ast_digest_idx_cache, name: "index_ex_rep"

    Exercise::Representation.update_all("exercise_id_and_ast_digest_idx_cache = CONCAT(exercise_id, '|', ast_digest)")
    Submission::Representation.joins(:submission).update_all("exercise_id_and_ast_digest_idx_cache = CONCAT(exercise_id, '|', ast_digest)")
  end
end
