# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_03_24_111409) do

  create_table "badges", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "type", null: false
    t.string "name", null: false
    t.string "rarity", null: false
    t.string "icon", null: false
    t.string "description", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_badges_on_name", unique: true
    t.index ["type"], name: "index_badges_on_type", unique: true
  end

  create_table "documents", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "uuid", null: false
    t.bigint "track_id"
    t.string "section", null: false
    t.string "slug", null: false
    t.string "git_repo", null: false
    t.string "git_path", null: false
    t.string "title", null: false
    t.string "nav_title"
    t.string "blurb"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug"], name: "index_documents_on_slug"
    t.index ["track_id"], name: "index_documents_on_track_id"
    t.index ["uuid"], name: "index_documents_on_uuid", unique: true
  end

  create_table "exercise_authorships", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["exercise_id", "user_id"], name: "index_exercise_authorships_on_exercise_id_and_user_id", unique: true
    t.index ["exercise_id"], name: "index_exercise_authorships_on_exercise_id"
    t.index ["user_id"], name: "index_exercise_authorships_on_user_id"
  end

  create_table "exercise_contributorships", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["exercise_id", "user_id"], name: "index_exercise_contributorships_on_exercise_id_and_user_id", unique: true
    t.index ["exercise_id"], name: "index_exercise_contributorships_on_exercise_id"
    t.index ["user_id"], name: "index_exercise_contributorships_on_user_id"
  end

  create_table "exercise_practiced_concepts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.bigint "track_concept_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["exercise_id", "track_concept_id"], name: "uniq", unique: true
    t.index ["exercise_id"], name: "index_exercise_practiced_concepts_on_exercise_id"
    t.index ["track_concept_id"], name: "index_exercise_practiced_concepts_on_track_concept_id"
  end

  create_table "exercise_prerequisites", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.bigint "track_concept_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["exercise_id", "track_concept_id"], name: "uniq", unique: true
    t.index ["exercise_id"], name: "index_exercise_prerequisites_on_exercise_id"
    t.index ["track_concept_id"], name: "index_exercise_prerequisites_on_track_concept_id"
  end

  create_table "exercise_representations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.bigint "source_submission_id", null: false
    t.text "ast", null: false
    t.string "ast_digest", null: false
    t.json "mapping"
    t.integer "feedback_type", limit: 1
    t.text "feedback_markdown"
    t.text "feedback_html"
    t.bigint "feedback_author_id"
    t.bigint "feedback_editor_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["exercise_id", "ast_digest"], name: "exercise_representations_unique", unique: true
    t.index ["exercise_id"], name: "index_exercise_representations_on_exercise_id"
    t.index ["feedback_author_id"], name: "index_exercise_representations_on_feedback_author_id"
    t.index ["feedback_editor_id"], name: "index_exercise_representations_on_feedback_editor_id"
    t.index ["source_submission_id"], name: "index_exercise_representations_on_source_submission_id"
  end

  create_table "exercise_taught_concepts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.bigint "track_concept_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["exercise_id", "track_concept_id"], name: "uniq", unique: true
    t.index ["exercise_id"], name: "index_exercise_taught_concepts_on_exercise_id"
    t.index ["track_concept_id"], name: "index_exercise_taught_concepts_on_track_concept_id"
  end

  create_table "exercises", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "track_id", null: false
    t.string "uuid", null: false
    t.string "type", null: false
    t.string "slug", null: false
    t.string "title", null: false
    t.string "blurb", limit: 350
    t.integer "difficulty", limit: 1, default: 1, null: false
    t.string "git_sha", null: false
    t.string "synced_to_git_sha", null: false
    t.integer "position", null: false
    t.boolean "deprecated", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["track_id", "uuid"], name: "index_exercises_on_track_id_and_uuid", unique: true
    t.index ["track_id"], name: "index_exercises_on_track_id"
    t.index ["uuid"], name: "index_exercises_on_uuid"
  end

  create_table "friendly_id_slugs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, length: { slug: 70, scope: 70 }
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", length: { slug: 140 }
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "github_organization_members", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "username", null: false
    t.boolean "alumnus", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["username"], name: "index_github_organization_members_on_username", unique: true
  end

  create_table "github_pull_request_reviews", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "github_pull_request_id", null: false
    t.string "node_id", null: false
    t.string "reviewer_username"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["github_pull_request_id"], name: "index_github_pull_request_reviews_on_github_pull_request_id"
    t.index ["node_id"], name: "index_github_pull_request_reviews_on_node_id", unique: true
  end

  create_table "github_pull_requests", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "node_id", null: false
    t.integer "number", null: false
    t.string "repo", null: false
    t.string "author_username"
    t.string "merged_by_username"
    t.string "title"
    t.json "data", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["node_id"], name: "index_github_pull_requests_on_node_id", unique: true
  end

  create_table "iterations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "solution_id", null: false
    t.bigint "submission_id", null: false
    t.string "uuid", null: false
    t.integer "idx", limit: 1, null: false
    t.string "snippet", limit: 1500
    t.boolean "published", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["solution_id"], name: "index_iterations_on_solution_id"
    t.index ["submission_id"], name: "index_iterations_on_submission_id", unique: true
  end

  create_table "mentor_discussion_posts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "uuid", null: false
    t.bigint "discussion_id", null: false
    t.bigint "iteration_id", null: false
    t.bigint "user_id", null: false
    t.text "content_markdown", null: false
    t.text "content_html", null: false
    t.boolean "seen_by_student", default: false, null: false
    t.boolean "seen_by_mentor", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["discussion_id"], name: "index_mentor_discussion_posts_on_discussion_id"
    t.index ["iteration_id"], name: "index_mentor_discussion_posts_on_iteration_id"
    t.index ["user_id"], name: "index_mentor_discussion_posts_on_user_id"
  end

  create_table "mentor_discussions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "uuid", null: false
    t.bigint "solution_id", null: false
    t.bigint "mentor_id", null: false
    t.bigint "request_id"
    t.integer "status", limit: 1, default: 0, null: false
    t.integer "rating", limit: 1
    t.datetime "awaiting_student_since"
    t.datetime "awaiting_mentor_since"
    t.datetime "finished_at"
    t.integer "finished_by", limit: 1
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["mentor_id"], name: "index_mentor_discussions_on_mentor_id"
    t.index ["request_id"], name: "index_mentor_discussions_on_request_id"
    t.index ["solution_id"], name: "index_mentor_discussions_on_solution_id"
  end

  create_table "mentor_requests", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "uuid", null: false
    t.bigint "solution_id", null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.text "comment_markdown", null: false
    t.text "comment_html", null: false
    t.bigint "locked_by_id"
    t.datetime "locked_until"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["locked_by_id"], name: "index_mentor_requests_on_locked_by_id"
    t.index ["solution_id"], name: "index_mentor_requests_on_solution_id"
  end

  create_table "mentor_student_relationships", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "mentor_id", null: false
    t.bigint "student_id", null: false
    t.boolean "favorited", default: false, null: false
    t.boolean "blocked_by_mentor", default: false, null: false
    t.boolean "blocked_by_student", default: false, null: false
    t.integer "num_discussions", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["mentor_id", "student_id"], name: "index_mentor_student_relationships_on_mentor_id_and_student_id", unique: true
    t.index ["mentor_id"], name: "index_mentor_student_relationships_on_mentor_id"
    t.index ["student_id"], name: "index_mentor_student_relationships_on_student_id"
  end

  create_table "mentor_testimonials", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "mentor_id", null: false
    t.bigint "student_id", null: false
    t.bigint "discussion_id", null: false
    t.string "uuid", null: false
    t.text "content", null: false
    t.boolean "revealed", default: false, null: false
    t.boolean "published", default: true, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["discussion_id"], name: "index_mentor_testimonials_on_discussion_id", unique: true
    t.index ["mentor_id"], name: "index_mentor_testimonials_on_mentor_id"
    t.index ["student_id"], name: "index_mentor_testimonials_on_student_id"
    t.index ["uuid"], name: "index_mentor_testimonials_on_uuid"
  end

  create_table "problem_reports", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "track_id"
    t.bigint "exercise_id"
    t.string "about_type"
    t.bigint "about_id"
    t.integer "type", limit: 1, default: 0, null: false
    t.text "content_markdown", null: false
    t.text "content_html", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["about_type", "about_id"], name: "index_problem_reports_on_about"
    t.index ["exercise_id"], name: "index_problem_reports_on_exercise_id"
    t.index ["track_id"], name: "index_problem_reports_on_track_id"
    t.index ["user_id"], name: "index_problem_reports_on_user_id"
  end

  create_table "scratchpad_pages", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "about_type", null: false
    t.bigint "about_id", null: false
    t.bigint "user_id", null: false
    t.text "content_markdown", null: false
    t.text "content_html", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["about_type", "about_id"], name: "index_scratchpad_pages_on_about"
    t.index ["user_id"], name: "index_scratchpad_pages_on_user_id"
  end

  create_table "solutions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "type", null: false
    t.bigint "user_id", null: false
    t.bigint "exercise_id", null: false
    t.string "uuid", null: false
    t.string "git_slug", null: false
    t.string "git_sha", null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.string "iteration_status"
    t.datetime "last_submitted_at"
    t.integer "num_iterations", limit: 1, default: 0, null: false
    t.string "snippet", limit: 1500
    t.datetime "downloaded_at"
    t.datetime "completed_at"
    t.datetime "published_at"
    t.integer "mentoring_status", limit: 1, default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["exercise_id"], name: "index_solutions_on_exercise_id"
    t.index ["user_id", "exercise_id"], name: "index_solutions_on_user_id_and_exercise_id", unique: true
    t.index ["user_id"], name: "index_solutions_on_user_id"
    t.index ["uuid"], name: "index_solutions_on_uuid", unique: true
  end

  create_table "submission_analyses", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "submission_id", null: false
    t.integer "ops_status", limit: 2, null: false
    t.json "data"
    t.string "tooling_job_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["submission_id"], name: "index_submission_analyses_on_submission_id"
  end

  create_table "submission_files", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "submission_id", null: false
    t.string "filename", null: false
    t.string "digest", null: false
    t.string "uri", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["submission_id"], name: "index_submission_files_on_submission_id"
  end

  create_table "submission_representations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "submission_id", null: false
    t.string "tooling_job_id", null: false
    t.integer "ops_status", limit: 2, null: false
    t.text "ast"
    t.string "ast_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["submission_id"], name: "index_submission_representations_on_submission_id"
  end

  create_table "submission_test_runs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "submission_id", null: false
    t.string "tooling_job_id", null: false
    t.string "status", null: false
    t.text "message"
    t.integer "ops_status", limit: 2, null: false
    t.json "raw_results", null: false
    t.integer "version", limit: 1, default: 0, null: false
    t.text "output"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["submission_id"], name: "index_submission_test_runs_on_submission_id"
  end

  create_table "submissions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "solution_id", null: false
    t.string "uuid", null: false
    t.integer "tests_status", default: 0, null: false
    t.integer "representation_status", default: 0, null: false
    t.integer "analysis_status", default: 0, null: false
    t.string "submitted_via", null: false
    t.string "git_slug", null: false
    t.string "git_sha", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["solution_id"], name: "index_submissions_on_solution_id"
    t.index ["uuid"], name: "index_submissions_on_uuid", unique: true
  end

  create_table "track_concepts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "track_id", null: false
    t.string "slug", null: false
    t.string "uuid", null: false
    t.string "name", null: false
    t.string "blurb", limit: 350
    t.string "synced_to_git_sha", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["track_id"], name: "index_track_concepts_on_track_id"
    t.index ["uuid"], name: "index_track_concepts_on_uuid", unique: true
  end

  create_table "tracks", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "slug", null: false
    t.string "title", null: false
    t.string "blurb", limit: 400, null: false
    t.string "repo_url", null: false
    t.string "synced_to_git_sha", null: false
    t.integer "num_exercises", limit: 3, default: 0, null: false
    t.integer "num_concepts", limit: 3, default: 0, null: false
    t.json "tags"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug"], name: "index_tracks_on_slug", unique: true
  end

  create_table "user_acquired_badges", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "uuid", null: false
    t.bigint "user_id", null: false
    t.bigint "badge_id", null: false
    t.boolean "revealed", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["badge_id"], name: "index_user_acquired_badges_on_badge_id"
    t.index ["user_id", "badge_id"], name: "index_user_acquired_badges_on_user_id_and_badge_id", unique: true
    t.index ["user_id"], name: "index_user_acquired_badges_on_user_id"
    t.index ["uuid"], name: "index_user_acquired_badges_on_uuid", unique: true
  end

  create_table "user_activities", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "type", null: false
    t.bigint "user_id", null: false
    t.bigint "track_id"
    t.bigint "exercise_id"
    t.bigint "solution_id"
    t.json "params", null: false
    t.datetime "occurred_at", null: false
    t.string "uniqueness_key", null: false
    t.integer "version", null: false
    t.json "rendering_data_cache", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["exercise_id"], name: "index_user_activities_on_exercise_id"
    t.index ["solution_id"], name: "index_user_activities_on_solution_id"
    t.index ["track_id"], name: "index_user_activities_on_track_id"
    t.index ["uniqueness_key"], name: "index_user_activities_on_uniqueness_key", unique: true
    t.index ["user_id"], name: "index_user_activities_on_user_id"
  end

  create_table "user_auth_tokens", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["token"], name: "index_user_auth_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_user_auth_tokens_on_user_id"
  end

  create_table "user_notifications", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "uuid", null: false
    t.bigint "user_id", null: false
    t.bigint "track_id"
    t.bigint "exercise_id"
    t.integer "status", limit: 1, default: 0, null: false
    t.string "path", null: false
    t.string "type", null: false
    t.integer "version", null: false
    t.json "params", null: false
    t.integer "email_status", limit: 1, default: 0, null: false
    t.string "uniqueness_key", null: false
    t.json "rendering_data_cache", null: false
    t.datetime "read_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["exercise_id"], name: "index_user_notifications_on_exercise_id"
    t.index ["track_id"], name: "index_user_notifications_on_track_id"
    t.index ["uniqueness_key"], name: "index_user_notifications_on_uniqueness_key", unique: true
    t.index ["user_id"], name: "index_user_notifications_on_user_id"
    t.index ["uuid"], name: "index_user_notifications_on_uuid", unique: true
  end

  create_table "user_profiles", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "twitter"
    t.string "website"
    t.string "github"
    t.string "linkedin"
    t.string "medium"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_profiles_on_user_id", unique: true
  end

  create_table "user_reputation_tokens", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "uuid", null: false
    t.string "type", null: false
    t.bigint "user_id", null: false
    t.bigint "exercise_id"
    t.bigint "track_id"
    t.string "uniqueness_key", null: false
    t.integer "value", null: false
    t.string "reason", null: false
    t.string "category", null: false
    t.json "params", null: false
    t.string "level"
    t.integer "version", null: false
    t.json "rendering_data_cache", null: false
    t.string "external_url"
    t.boolean "seen", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["exercise_id"], name: "index_user_reputation_tokens_on_exercise_id"
    t.index ["track_id"], name: "index_user_reputation_tokens_on_track_id"
    t.index ["uniqueness_key", "user_id"], name: "index_user_reputation_tokens_on_uniqueness_key_and_user_id", unique: true
    t.index ["user_id"], name: "index_user_reputation_tokens_on_user_id"
  end

  create_table "user_track_learnt_concepts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_track_id", null: false
    t.bigint "track_concept_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["track_concept_id"], name: "index_user_track_learnt_concepts_on_track_concept_id"
    t.index ["user_track_id"], name: "index_user_track_learnt_concepts_on_user_track_id"
  end

  create_table "user_track_mentorships", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "track_id", null: false
    t.boolean "last_viewed", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["track_id"], name: "index_user_track_mentorships_on_track_id"
    t.index ["user_id", "track_id"], name: "index_user_track_mentorships_on_user_id_and_track_id", unique: true
    t.index ["user_id"], name: "index_user_track_mentorships_on_user_id"
  end

  create_table "user_tracks", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "track_id", null: false
    t.json "summary_data", null: false
    t.string "summary_key"
    t.boolean "anonymous_during_mentoring", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["track_id"], name: "index_user_tracks_on_track_id"
    t.index ["user_id", "track_id"], name: "index_user_tracks_on_user_id_and_track_id", unique: true
    t.index ["user_id"], name: "index_user_tracks_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "handle", null: false
    t.string "name", null: false
    t.string "provider"
    t.string "uid"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "accepted_privacy_policy_at"
    t.datetime "accepted_terms_at"
    t.datetime "became_mentor_at"
    t.string "github_username"
    t.integer "reputation", default: 0, null: false
    t.json "roles"
    t.text "bio"
    t.string "avatar_url"
    t.string "location"
    t.string "pronouns"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["handle"], name: "index_users_on_handle", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "documents", "tracks"
  add_foreign_key "exercise_authorships", "exercises"
  add_foreign_key "exercise_authorships", "users"
  add_foreign_key "exercise_contributorships", "exercises"
  add_foreign_key "exercise_contributorships", "users"
  add_foreign_key "exercise_practiced_concepts", "exercises"
  add_foreign_key "exercise_practiced_concepts", "track_concepts"
  add_foreign_key "exercise_prerequisites", "exercises"
  add_foreign_key "exercise_prerequisites", "track_concepts"
  add_foreign_key "exercise_representations", "exercises"
  add_foreign_key "exercise_representations", "submissions", column: "source_submission_id"
  add_foreign_key "exercise_representations", "users", column: "feedback_author_id"
  add_foreign_key "exercise_representations", "users", column: "feedback_editor_id"
  add_foreign_key "exercise_taught_concepts", "exercises"
  add_foreign_key "exercise_taught_concepts", "track_concepts"
  add_foreign_key "exercises", "tracks"
  add_foreign_key "github_pull_request_reviews", "github_pull_requests"
  add_foreign_key "iterations", "solutions"
  add_foreign_key "iterations", "submissions"
  add_foreign_key "mentor_discussion_posts", "iterations"
  add_foreign_key "mentor_discussion_posts", "mentor_discussions", column: "discussion_id"
  add_foreign_key "mentor_discussion_posts", "users"
  add_foreign_key "mentor_discussions", "mentor_requests", column: "request_id"
  add_foreign_key "mentor_discussions", "solutions"
  add_foreign_key "mentor_discussions", "users", column: "mentor_id"
  add_foreign_key "mentor_requests", "solutions"
  add_foreign_key "mentor_requests", "users", column: "locked_by_id"
  add_foreign_key "mentor_student_relationships", "users", column: "mentor_id"
  add_foreign_key "mentor_student_relationships", "users", column: "student_id"
  add_foreign_key "mentor_testimonials", "mentor_discussions", column: "discussion_id"
  add_foreign_key "mentor_testimonials", "users", column: "mentor_id"
  add_foreign_key "mentor_testimonials", "users", column: "student_id"
  add_foreign_key "problem_reports", "exercises"
  add_foreign_key "problem_reports", "tracks"
  add_foreign_key "problem_reports", "users"
  add_foreign_key "scratchpad_pages", "users"
  add_foreign_key "solutions", "exercises"
  add_foreign_key "solutions", "users"
  add_foreign_key "submission_analyses", "submissions"
  add_foreign_key "submission_files", "submissions"
  add_foreign_key "submission_representations", "submissions"
  add_foreign_key "submission_test_runs", "submissions"
  add_foreign_key "submissions", "solutions"
  add_foreign_key "track_concepts", "tracks"
  add_foreign_key "user_acquired_badges", "badges"
  add_foreign_key "user_acquired_badges", "users"
  add_foreign_key "user_activities", "exercises"
  add_foreign_key "user_activities", "solutions"
  add_foreign_key "user_activities", "tracks"
  add_foreign_key "user_activities", "users"
  add_foreign_key "user_auth_tokens", "users"
  add_foreign_key "user_notifications", "exercises"
  add_foreign_key "user_notifications", "tracks"
  add_foreign_key "user_notifications", "users"
  add_foreign_key "user_profiles", "users"
  add_foreign_key "user_reputation_tokens", "exercises"
  add_foreign_key "user_reputation_tokens", "tracks"
  add_foreign_key "user_reputation_tokens", "users"
  add_foreign_key "user_track_learnt_concepts", "track_concepts"
  add_foreign_key "user_track_learnt_concepts", "user_tracks"
  add_foreign_key "user_track_mentorships", "tracks"
  add_foreign_key "user_track_mentorships", "users"
  add_foreign_key "user_tracks", "tracks"
  add_foreign_key "user_tracks", "users"
end
