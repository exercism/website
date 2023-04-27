class RemoveOldTables < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    drop_table :blog_comments
    drop_table :changelog_entries
    drop_table :changelog_entry_tweets
    drop_table :contributors
    drop_table :contributor_team_memberships
    drop_table :contributor_teams
    drop_table :delayed_jobs
    drop_table :exercise_topics
    drop_table :flipper_features
    drop_table :flipper_gates
    drop_table :ignored_solution_mentorships
    drop_table :infrastructure_test_runner_versions
    drop_table :infrastructure_test_runners
    drop_table :maintainers
    drop_table :mentors
    drop_table :reactions
    drop_table :repo_update_fetches
    drop_table :repo_updates
    drop_table :solution_locks
    drop_table :testimonials
    drop_table :topics
    drop_table :user_email_logs

    drop_table :v2_discussion_posts
    drop_table :v2_iteration_analyses
    drop_table :v2_notifications
    drop_table :v2_submission_test_runs
    drop_table :v2_submissions
  end
end
