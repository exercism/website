class AddPositionToExerciseArticles < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :exercise_articles, :position, :integer, null: true, limit: 1
    add_index :exercise_articles, [:exercise_id, :position]

    # The positions will be fixed manually by running Git::SyncTrack.()
    Exercise::Article.update_all(position: 0)

    change_column_null :exercise_articles, :position, false
  end
end
