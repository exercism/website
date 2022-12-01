class AddBuildStatusIndexes < ActiveRecord::Migration[7.0]
  def change
    unless Rails.env.production?
      add_index :mentor_requests, %i[track_id exercise_id], if_not_exists: true
      add_index :user_reputation_tokens, %i[track_id category external_url], name: 'index_user_reputation_tokens_on_track_id_category_external_url', if_not_exists: true
      add_index :submission_analyses, %i[track_id num_comments], if_not_exists: true
      add_index :submissions, %i[track_id tests_status], if_not_exists: true
    end
  end
end
