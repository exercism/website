class AddSearchFieldsForRepresenters < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :solutions, :published_exercise_representation_id, :bigint, null: true
    add_foreign_key :solutions, :exercise_representations, column: :published_exercise_representation_id

    add_column :exercise_representations, :num_published_solutions, :smallint, null: false, default: 0
  end
end
