class SyncIndexesWithProduction < ActiveRecord::Migration[7.1]
  def change
    return if Rails.env.production?

    # schema.rb had drifted from production in both directions. This brings it
    # back in line. Everything here has already been applied to production by
    # hand, so this migration is bookkeeping only.
    #
    # Part 1 removes 15 indexes dropped from production on 2026-08-20. They
    # were identified via performance_schema.table_io_waits_summary_by_index_usage
    # over a 155-day uptime window on the writer (we have no replicas, so every
    # query in the system is covered by that sample). Each had COUNT_STAR = 0.
    #
    # The bulk of the reclaimed space was three indexes leading on git hashes:
    # submissions-git-optimiser-1 (35GB), submissions-git-optimiser-2 (15GB)
    # and submissions-test-runs-git-optimiser-1 (15.6GB). The git optimiser was
    # rekeyed at some point from git_sha to git_important_files_hash, and the
    # sha-leading indexes were left behind. The hash-leading equivalents are
    # still very much alive (submissions-test-runs-git-optimiser-2 serves 17.6M
    # reads), so only the sha-leading ones went.
    #
    # The rest were either exact duplicates (mentor_selection_idx_2 is
    # byte-identical to _idx_1) or strict prefixes of a wider index that the
    # optimiser was already preferring.

    remove_index :bootcamp_exercise_concepts, name: "index_bootcamp_exercise_concepts_on_exercise_id", if_exists: true
    remove_index :exercise_representations, name: "index_exercise_representation_type_exercise_last_submitted_at", if_exists: true
    remove_index :exercise_representations, name: "search_ex_2", if_exists: true
    remove_index :exercise_representations, name: "search_ex_3", if_exists: true
    remove_index :solution_tags, name: "index_solution_tags_on_solution_id", if_exists: true
    remove_index :solutions, name: "mentor_selection_idx_1", if_exists: true
    remove_index :solutions, name: "mentor_selection_idx_2", if_exists: true
    remove_index :solutions, name: "solutions_popular_new", if_exists: true
    remove_index :submission_representations, name: "index_submission_representations_on_track_id_and_id", if_exists: true
    remove_index :submission_test_runs, name: "submissions-test-runs-git-optimiser-1", if_exists: true
    remove_index :submissions, name: "index_submissions_on_approach_id", if_exists: true
    remove_index :submissions, name: "submissions-git-optimiser-1", if_exists: true
    remove_index :submissions, name: "submissions-git-optimiser-2", if_exists: true
    remove_index :user_reputation_periods, name: "search-2", if_exists: true
    remove_index :user_reputation_periods, name: "search-5", if_exists: true

    # Part 2 adds indexes that exist on production but were never captured in
    # schema.rb, because they were created by hand and no migration followed.
    # Several are load-bearing: index_solutions_er_lookup is the single busiest
    # index on solutions at 140M reads, and index_iterations_on_created_at_and_solution_id
    # serves 42M. A database rebuilt from schema.rb today would be missing both.

    add_index :exercise_representations, %i[oldest_solution_id],
      name: "exercise_representations_oldest_solution_id", if_not_exists: true
    add_index :exercise_representations, %i[feedback_type num_submissions track_id],
      name: "exercise_representations_staff_context_3", if_not_exists: true
    add_index :exercise_representations, %i[track_id feedback_type source_submission_id],
      name: "index_on_exercise_representations_covering_1", if_not_exists: true

    add_index :exercises, %i[track_id slug],
      name: "index_exercises_on_track_id_and_slug", if_not_exists: true

    add_index :github_pull_request_reviews, %i[reviewer_username],
      name: "index_github_pull_request_reviews_on_reviewer_username", if_not_exists: true
    add_index :github_pull_requests, %i[author_username state],
      name: "index_github_pull_requests_on_author_username_and_state", if_not_exists: true
    add_index :github_pull_requests, %i[merged_by_username state],
      name: "index_github_pull_requests_on_merged_by_username_and_state", if_not_exists: true

    add_index :iterations, %i[created_at solution_id],
      name: "index_iterations_on_created_at_and_solution_id", if_not_exists: true

    add_index :solution_tags, %i[track_id],
      name: "index_solution_tags_on_track_id", if_not_exists: true
    add_index :solution_tags, %i[track_id tag],
      name: "index_solution_tags_on_track_id_and_tag", if_not_exists: true

    add_index :solutions, %i[published_exercise_representation_id status user_id],
      name: "index_solutions_er_lookup", if_not_exists: true
    add_index :solutions, %i[exercise_id status],
      name: "index_solutions_on_exercise_id_and_status", if_not_exists: true
    add_index :solutions, %i[published_exercise_representation_id],
      name: "index_solutions_on_published_exercise_representation_id", if_not_exists: true
    add_index :solutions, %i[user_id status allow_comments],
      name: "index_solutions_on_user_id_and_status_and_allow_comments", if_not_exists: true

    add_index :submission_analyses, %i[tooling_job_id],
      name: "index_submission_analyses_on_tooling_job_id", unique: true, if_not_exists: true
    add_index :submission_representations, %i[exercise_id_and_ast_digest_idx_cache submission_id],
      name: "index_on_submission_representations_for_num_submissions", if_not_exists: true
    add_index :submission_representations, %i[exercise_id_and_ast_digest_idx_cache id],
      name: "index_submission_representations_on_digest_and_id", if_not_exists: true
    add_index :submission_representations, %i[tooling_job_id],
      name: "index_submission_representations_on_tooling_job_id", unique: true, if_not_exists: true
    add_index :submission_test_runs, %i[tooling_job_id],
      name: "index_submission_test_runs_on_tooling_job_id", unique: true, if_not_exists: true

    add_index :user_data, %i[seniority],
      name: "index_user_data_on_seniority", if_not_exists: true

    add_index :user_notifications, %i[user_id status id],
      name: "index_user_notifications_on_user_id_and_status_and_id", if_not_exists: true

    add_index :user_reputation_tokens, %i[user_id category id],
      name: "index_user_reputation_tokens_on_user_id_and_category_and_id", if_not_exists: true
    add_index :user_reputation_tokens, %i[user_id id],
      name: "index_user_reputation_tokens_on_user_id_and_id", if_not_exists: true
    add_index :user_reputation_tokens, %i[user_id seen id],
      name: "index_user_reputation_tokens_on_user_id_and_seen_and_id", if_not_exists: true
    add_index :user_reputation_tokens, %i[user_id track_id id],
      name: "index_user_reputation_tokens_on_user_id_and_track_id_and_id", if_not_exists: true
    add_index :user_reputation_tokens, %i[user_id category earned_on],
      name: "index_user_reputation_tokens_on_user_id_category_earned_on", if_not_exists: true
    add_index :user_reputation_tokens, %i[user_id track_id value],
      name: "rep_all_values_covering", if_not_exists: true

    # The reputation leaderboard sorts by reputation descending, so these carry
    # a DESC key part on that column. The plain search-1 and search-3 remain
    # alongside them; search-2 and search-5 were the unused pair and are
    # removed above.
    add_index :user_reputation_periods, %i[period category about track_id reputation],
      name: "search-1-desc", order: { reputation: :desc }, if_not_exists: true
    add_index :user_reputation_periods, %i[period category about reputation],
      name: "search-2-desc", order: { reputation: :desc }, if_not_exists: true
    add_index :user_reputation_periods, %i[period category about track_id user_handle reputation],
      name: "search-3-desc", order: { reputation: :desc }, if_not_exists: true
    add_index :user_reputation_periods, %i[period category about track_id reputation id],
      name: "search-5-desc", order: { reputation: :desc }, if_not_exists: true
    add_index :user_reputation_periods, %i[period category about user_id reputation],
      name: "search-6-desc", order: { reputation: :desc }, if_not_exists: true
    add_index :user_reputation_periods, %i[period category about track_id user_id reputation],
      name: "search-7-desc", order: { reputation: :desc }, if_not_exists: true

    # Part 3 drops two index declarations that production has never had.
    #
    # fk_rails_3d3fa40f89 is the old name for what production now calls
    # index_solutions_on_published_exercise_representation_id (added above), so
    # schema.rb was declaring the same column twice. It is not a foreign key
    # despite the name: solutions' only FKs are fk_rails_16788386df,
    # fk_rails_8c0841e614 and fk_rails_f83c42cef4.
    #
    # index_site_updates_on_track_id is a strict prefix of
    # index_site_updates_on_track_id_and_published_at_and_id, which is what
    # actually backs the track_id foreign key on production.
    remove_index :solutions, name: "fk_rails_3d3fa40f89", if_exists: true
    remove_index :site_updates, name: "index_site_updates_on_track_id", if_exists: true
  end
end
