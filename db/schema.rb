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

ActiveRecord::Schema.define(version: 2020_06_08_143333) do

  create_table "badges", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "type"], name: "index_badges_on_user_id_and_type", unique: true
    t.index ["user_id"], name: "index_badges_on_user_id"
  end

  create_table "exercise_prerequisites", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.bigint "track_concept_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["exercise_id", "track_concept_id"], name: "index_exercise_prerequisites_on_exercise_id_and_track_concept_id", unique: true
    t.index ["exercise_id"], name: "index_exercise_prerequisites_on_exercise_id"
    t.index ["track_concept_id"], name: "index_exercise_prerequisites_on_track_concept_id"
  end

  create_table "exercise_representations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.bigint "source_iteration_id", null: false
    t.integer "exercise_version", limit: 2, null: false
    t.text "ast", null: false
    t.string "ast_digest", null: false
    t.json "mapping", null: false
    t.text "feedback_markdown"
    t.text "feedback_html"
    t.bigint "feedback_author_id"
    t.bigint "feedback_editor_id"
    t.integer "action", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["exercise_id", "exercise_version", "ast_digest"], name: "exercise_representations_unique", unique: true
    t.index ["exercise_id"], name: "index_exercise_representations_on_exercise_id"
    t.index ["feedback_author_id"], name: "index_exercise_representations_on_feedback_author_id"
    t.index ["feedback_editor_id"], name: "index_exercise_representations_on_feedback_editor_id"
    t.index ["source_iteration_id"], name: "index_exercise_representations_on_source_iteration_id"
  end

  create_table "exercises", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "track_id", null: false
    t.string "uuid", null: false
    t.string "type", null: false
    t.string "slug", null: false
    t.string "title", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["track_id"], name: "index_exercises_on_track_id"
  end

  create_table "iteration_analyses", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "iteration_id", null: false
    t.integer "ops_status", limit: 2, null: false
    t.text "ops_message"
    t.json "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["iteration_id"], name: "index_iteration_analyses_on_iteration_id"
  end

  create_table "iteration_discussion_posts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "iteration_id", null: false
    t.bigint "user_id", null: false
    t.string "source_type"
    t.bigint "source_id"
    t.text "content_markdown", null: false
    t.text "content_html", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["iteration_id"], name: "index_iteration_discussion_posts_on_iteration_id"
    t.index ["source_type", "source_id"], name: "discussion_post_source_idx"
    t.index ["user_id"], name: "index_iteration_discussion_posts_on_user_id"
  end

  create_table "iteration_files", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "iteration_id", null: false
    t.string "uuid", null: false
    t.string "filename", null: false
    t.string "digest", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["iteration_id"], name: "index_iteration_files_on_iteration_id"
  end

  create_table "iteration_representations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "iteration_id", null: false
    t.integer "ops_status", limit: 2, null: false
    t.text "ops_message"
    t.text "ast"
    t.string "ast_digest", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["iteration_id"], name: "index_iteration_representations_on_iteration_id"
  end

  create_table "iteration_test_runs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "iteration_id", null: false
    t.string "status", null: false
    t.text "message"
    t.json "tests"
    t.integer "ops_status", limit: 2, null: false
    t.text "ops_message"
    t.json "raw_results", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["iteration_id"], name: "index_iteration_test_runs_on_iteration_id"
  end

  create_table "iterations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
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
    t.index ["solution_id"], name: "index_iterations_on_solution_id"
  end

  create_table "notifications", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "type", null: false
    t.integer "version", null: false
    t.json "params", null: false
    t.integer "email_status", limit: 1, default: 0, null: false
    t.string "anti_duplicate_key", null: false
    t.datetime "read_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "solution_mentor_discussions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "solution_id", null: false
    t.bigint "mentor_id", null: false
    t.bigint "request_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["mentor_id"], name: "index_solution_mentor_discussions_on_mentor_id"
    t.index ["request_id"], name: "index_solution_mentor_discussions_on_request_id"
    t.index ["solution_id"], name: "index_solution_mentor_discussions_on_solution_id"
  end

  create_table "solution_mentor_requests", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "solution_id", null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.integer "type", limit: 1, null: false
    t.text "comment"
    t.bigint "locked_by_id"
    t.datetime "locked_until"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["locked_by_id"], name: "index_solution_mentor_requests_on_locked_by_id"
    t.index ["solution_id"], name: "index_solution_mentor_requests_on_solution_id"
  end

  create_table "solutions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "type", null: false
    t.bigint "user_id", null: false
    t.bigint "exercise_id", null: false
    t.string "uuid", null: false
    t.integer "status", default: 0, null: false
    t.string "git_slug", null: false
    t.string "git_sha", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["exercise_id"], name: "index_solutions_on_exercise_id"
    t.index ["user_id", "exercise_id"], name: "index_solutions_on_user_id_and_exercise_id", unique: true
    t.index ["user_id"], name: "index_solutions_on_user_id"
  end

  create_table "track_concepts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "track_id", null: false
    t.string "uuid", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["track_id"], name: "index_track_concepts_on_track_id"
  end

  create_table "tracks", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "slug", null: false
    t.string "title", null: false
    t.string "repo_url", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_reputation_acquisitions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "reason_object_type"
    t.bigint "reason_object_id"
    t.integer "amount", null: false
    t.string "category", null: false
    t.string "reason", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["reason_object_type", "reason_object_id"], name: "reason_object_index"
    t.index ["user_id"], name: "index_user_reputation_acquisitions_on_user_id"
  end

  create_table "user_track_concepts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_track_id", null: false
    t.bigint "track_concept_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["track_concept_id"], name: "index_user_track_concepts_on_track_concept_id"
    t.index ["user_track_id"], name: "index_user_track_concepts_on_user_track_id"
  end

  create_table "user_tracks", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "track_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["track_id"], name: "index_user_tracks_on_track_id"
    t.index ["user_id", "track_id"], name: "index_user_tracks_on_user_id_and_track_id", unique: true
    t.index ["user_id"], name: "index_user_tracks_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "handle", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "featured_badge_id"
    t.index ["featured_badge_id"], name: "index_users_on_featured_badge_id"
  end

  add_foreign_key "badges", "users"
  add_foreign_key "exercise_prerequisites", "exercises"
  add_foreign_key "exercise_prerequisites", "track_concepts"
  add_foreign_key "exercise_representations", "exercises"
  add_foreign_key "exercise_representations", "iterations", column: "source_iteration_id"
  add_foreign_key "exercise_representations", "users", column: "feedback_author_id"
  add_foreign_key "exercise_representations", "users", column: "feedback_editor_id"
  add_foreign_key "exercises", "tracks"
  add_foreign_key "iteration_analyses", "iterations"
  add_foreign_key "iteration_discussion_posts", "iterations"
  add_foreign_key "iteration_discussion_posts", "users"
  add_foreign_key "iteration_files", "iterations"
  add_foreign_key "iteration_representations", "iterations"
  add_foreign_key "iteration_test_runs", "iterations"
  add_foreign_key "iterations", "solutions"
  add_foreign_key "notifications", "users"
  add_foreign_key "solution_mentor_discussions", "solution_mentor_requests", column: "request_id"
  add_foreign_key "solution_mentor_discussions", "solutions"
  add_foreign_key "solution_mentor_discussions", "users", column: "mentor_id"
  add_foreign_key "solution_mentor_requests", "solutions"
  add_foreign_key "solution_mentor_requests", "users", column: "locked_by_id"
  add_foreign_key "solutions", "exercises"
  add_foreign_key "solutions", "users"
  add_foreign_key "track_concepts", "tracks"
  add_foreign_key "user_reputation_acquisitions", "users"
  add_foreign_key "user_track_concepts", "track_concepts"
  add_foreign_key "user_track_concepts", "user_tracks"
  add_foreign_key "user_tracks", "tracks"
  add_foreign_key "user_tracks", "users"
  add_foreign_key "users", "badges", column: "featured_badge_id"
end
