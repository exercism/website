class ChangeJsonToText < ActiveRecord::Migration[6.1]
  def up
    %w{
      exercise_representations mapping
      github_pull_requests data
      submission_analyses data
      submission_test_runs raw_results
      user_activities params
      user_activities rendering_data_cache
      user_notifications params
      user_notifications rendering_data_cache
      user_reputation_tokens params
      user_reputation_tokens rendering_data_cache
      user_tracks summary_data

    }.each_slice(2) do |table, column|
      change_column table, column, :text
    end
  end

  def down
  end
end
