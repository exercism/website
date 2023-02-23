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

ActiveRecord::Schema[7.0].define(version: 2023_02_23_145455) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "badges", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "type", null: false
    t.string "name", null: false
    t.string "rarity", null: false
    t.string "icon", null: false
    t.string "description", null: false
    t.integer "num_awardees", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_badges_on_name", unique: true
    t.index ["type"], name: "index_badges_on_type", unique: true
  end

  create_table "blog_posts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.string "uuid", null: false
    t.string "slug", null: false
    t.string "category", null: false
    t.datetime "published_at", null: false
    t.string "title", null: false
    t.text "description"
    t.string "marketing_copy", limit: 280
    t.string "image_url"
    t.string "youtube_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_blog_posts_on_author_id"
    t.index ["uuid"], name: "index_blog_posts_on_uuid", unique: true
  end

  create_table "cohort_memberships", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "introduction", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.bigint "cohort_id", null: false
    t.index ["cohort_id"], name: "index_cohort_memberships_on_cohort_id"
    t.index ["user_id", "cohort_id"], name: "index_cohort_memberships_on_user_id_and_cohort_id", unique: true
    t.index ["user_id"], name: "index_cohort_memberships_on_user_id"
  end

  create_table "cohorts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "track_id", null: false
    t.string "slug", null: false
    t.string "name", null: false
    t.integer "capacity", default: 0, null: false
    t.datetime "begins_at", null: false
    t.datetime "ends_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_cohorts_on_slug", unique: true
    t.index ["track_id"], name: "index_cohorts_on_track_id"
  end

  create_table "community_stories", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "interviewer_id", null: false
    t.bigint "interviewee_id", null: false
    t.string "uuid", null: false
    t.string "slug", null: false
    t.string "title", null: false
    t.string "blurb", limit: 280, null: false
    t.string "thumbnail_url", null: false
    t.string "image_url", null: false
    t.string "youtube_id", null: false
    t.integer "length_in_minutes", limit: 2, null: false
    t.datetime "published_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["interviewee_id"], name: "index_community_stories_on_interviewee_id"
    t.index ["interviewer_id"], name: "index_community_stories_on_interviewer_id"
    t.index ["uuid"], name: "index_community_stories_on_uuid", unique: true
  end

  create_table "community_videos", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "track_id"
    t.bigint "exercise_id"
    t.bigint "author_id"
    t.bigint "submitted_by_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "platform", null: false
    t.string "title", null: false
    t.string "url", null: false
    t.string "watch_id", null: false
    t.string "embed_id", null: false
    t.string "channel_name", null: false
    t.string "thumbnail_url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "channel_url", null: false
    t.string "embed_url", null: false
    t.index ["author_id"], name: "index_community_videos_on_author_id"
    t.index ["exercise_id"], name: "index_community_videos_on_exercise_id"
    t.index ["submitted_by_id"], name: "index_community_videos_on_submitted_by_id"
    t.index ["track_id"], name: "index_community_videos_on_track_id"
    t.index ["watch_id", "exercise_id"], name: "index_community_videos_on_watch_id_and_exercise_id", unique: true
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_documents_on_slug"
    t.index ["track_id"], name: "index_documents_on_track_id"
    t.index ["uuid"], name: "index_documents_on_uuid", unique: true
  end

  create_table "donations_payments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "subscription_id"
    t.string "stripe_id", null: false
    t.string "stripe_receipt_url", null: false
    t.decimal "amount_in_cents", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "email_status", limit: 1, default: 0, null: false
    t.index ["stripe_id"], name: "index_donations_payments_on_stripe_id", unique: true
    t.index ["subscription_id"], name: "index_donations_payments_on_subscription_id"
    t.index ["user_id"], name: "index_donations_payments_on_user_id"
  end

  create_table "donations_subscriptions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "stripe_id", null: false
    t.boolean "active", default: true, null: false
    t.decimal "amount_in_cents", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "email_status", limit: 1, default: 0, null: false
    t.index ["stripe_id"], name: "index_donations_subscriptions_on_stripe_id", unique: true
    t.index ["user_id"], name: "index_donations_subscriptions_on_user_id"
  end

  create_table "exercise_approach_authorships", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_approach_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_approach_id", "user_id"], name: "index_exercise_approach_author_approach_id_user_id", unique: true
    t.index ["exercise_approach_id"], name: "index_exercise_approaches_authorships_on_approach_id"
    t.index ["user_id"], name: "index_exercise_approach_authorships_on_user_id"
  end

  create_table "exercise_approach_contributorships", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_approach_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_approach_id", "user_id"], name: "index_exercise_approach_contributor_approach_id_user_id", unique: true
    t.index ["exercise_approach_id"], name: "index_exercise_approaches_contributorships_on_approach_id"
    t.index ["user_id"], name: "index_exercise_approach_contributorships_on_user_id"
  end

  create_table "exercise_approach_introduction_authorships", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id", "user_id"], name: "index_exercise_approach_intro_authors_on_exercise_and_user", unique: true
    t.index ["exercise_id"], name: "index_exercise_approach_introduction_authorships_on_exercise_id"
    t.index ["user_id"], name: "index_exercise_approach_introduction_authorships_on_user_id"
  end

  create_table "exercise_approach_introduction_contributorships", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id", "user_id"], name: "index_exercise_approach_intro_contris_on_exercise_and_user", unique: true
    t.index ["exercise_id"], name: "index_exercise_approach_intro_contributorships_on_exercise_id"
    t.index ["user_id"], name: "index_exercise_approach_introduction_contributorships_on_user_id"
  end

  create_table "exercise_approaches", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.string "uuid", null: false
    t.string "slug", null: false
    t.string "title", null: false
    t.string "blurb", limit: 350, null: false
    t.string "synced_to_git_sha", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id", "uuid"], name: "index_exercise_approaches_on_exercise_id_and_uuid", unique: true
    t.index ["exercise_id"], name: "index_exercise_approaches_on_exercise_id"
    t.index ["uuid"], name: "index_exercise_approaches_on_uuid"
  end

  create_table "exercise_article_authorships", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_article_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_article_id", "user_id"], name: "index_exercise_article_author_article_id_user_id", unique: true
    t.index ["exercise_article_id"], name: "index_exercise_article_authorships_on_article_id"
    t.index ["user_id"], name: "index_exercise_article_authorships_on_user_id"
  end

  create_table "exercise_article_contributorships", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_article_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_article_id", "user_id"], name: "index_exercise_article_contributor_article_id_user_id", unique: true
    t.index ["exercise_article_id"], name: "index_exercise_article_contributorships_on_article_id"
    t.index ["user_id"], name: "index_exercise_article_contributorships_on_user_id"
  end

  create_table "exercise_articles", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.string "uuid", null: false
    t.string "slug", null: false
    t.string "title", null: false
    t.string "blurb", limit: 350, null: false
    t.string "synced_to_git_sha", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id", "uuid"], name: "index_exercise_articles_on_exercise_id_and_uuid", unique: true
    t.index ["exercise_id"], name: "index_exercise_articles_on_exercise_id"
    t.index ["uuid"], name: "index_exercise_articles_on_uuid"
  end

  create_table "exercise_authorships", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id", "user_id"], name: "index_exercise_authorships_on_exercise_id_and_user_id", unique: true
    t.index ["exercise_id"], name: "index_exercise_authorships_on_exercise_id"
    t.index ["user_id"], name: "index_exercise_authorships_on_user_id"
  end

  create_table "exercise_contributorships", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id", "user_id"], name: "index_exercise_contributorships_on_exercise_id_and_user_id", unique: true
    t.index ["exercise_id"], name: "index_exercise_contributorships_on_exercise_id"
    t.index ["user_id"], name: "index_exercise_contributorships_on_user_id"
  end

  create_table "exercise_practiced_concepts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.bigint "track_concept_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id", "track_concept_id"], name: "uniq", unique: true
    t.index ["exercise_id"], name: "index_exercise_practiced_concepts_on_exercise_id"
    t.index ["track_concept_id"], name: "index_exercise_practiced_concepts_on_track_concept_id"
  end

  create_table "exercise_prerequisites", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.bigint "track_concept_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id", "track_concept_id"], name: "uniq", unique: true
    t.index ["exercise_id"], name: "index_exercise_prerequisites_on_exercise_id"
    t.index ["track_concept_id"], name: "index_exercise_prerequisites_on_track_concept_id"
  end

  create_table "exercise_representations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.bigint "source_submission_id", null: false
    t.text "ast", null: false
    t.string "ast_digest", null: false
    t.text "mapping"
    t.integer "feedback_type", limit: 1
    t.text "feedback_markdown"
    t.text "feedback_html"
    t.bigint "feedback_author_id"
    t.bigint "feedback_editor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "num_submissions", default: 1, null: false
    t.datetime "last_submitted_at", default: -> { "CURRENT_TIMESTAMP(6)" }, null: false
    t.string "uuid", null: false
    t.bigint "track_id"
    t.datetime "feedback_added_at"
    t.integer "representer_version", limit: 2, default: 1, null: false
    t.integer "exercise_version", limit: 2, default: 1, null: false
    t.integer "draft_feedback_type", limit: 1
    t.text "draft_feedback_markdown"
    t.index ["exercise_id", "ast_digest", "representer_version", "exercise_version"], name: "exercise_representations_guard", unique: true
    t.index ["feedback_author_id", "track_id", "last_submitted_at"], name: "index_exercise_representation_author_track_last_submitted_at", order: { last_submitted_at: :desc }
    t.index ["feedback_author_id", "track_id", "num_submissions"], name: "index_exercise_representation_author_track_num_submissions", order: { num_submissions: :desc }
    t.index ["feedback_author_id"], name: "index_exercise_representations_on_feedback_author_id"
    t.index ["feedback_editor_id"], name: "index_exercise_representations_on_feedback_editor_id"
    t.index ["feedback_type", "track_id", "last_submitted_at"], name: "index_exercise_representation_type_track_last_submitted_at", order: { last_submitted_at: :desc }
    t.index ["feedback_type", "track_id", "num_submissions"], name: "index_exercise_representation_type_track_num_submissions", order: { num_submissions: :desc }
    t.index ["source_submission_id"], name: "index_exercise_representations_on_source_submission_id"
    t.index ["track_id"], name: "index_exercise_representations_on_track_id"
  end

  create_table "exercise_taught_concepts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.bigint "track_concept_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "blurb", limit: 350, null: false
    t.integer "difficulty", limit: 1, default: 1, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.string "git_sha", null: false
    t.string "synced_to_git_sha", null: false
    t.string "git_important_files_hash", null: false
    t.integer "position", null: false
    t.string "icon_name", null: false
    t.integer "median_wait_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_test_runner", default: false, null: false
    t.integer "num_published_solutions", default: 0, null: false
    t.boolean "has_approaches", default: false, null: false
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

  create_table "github_issue_labels", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "github_issue_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["github_issue_id", "name"], name: "index_github_issue_labels_on_github_issue_id_and_name", unique: true
    t.index ["github_issue_id"], name: "index_github_issue_labels_on_github_issue_id"
  end

  create_table "github_issues", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "node_id", null: false
    t.integer "number", null: false
    t.string "title", null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.string "repo", null: false
    t.string "opened_by_username"
    t.datetime "opened_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["node_id"], name: "index_github_issues_on_node_id", unique: true
  end

  create_table "github_organization_members", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "username", null: false
    t.boolean "alumnus", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_github_organization_members_on_username", unique: true
  end

  create_table "github_pull_request_reviews", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "github_pull_request_id", null: false
    t.string "node_id", null: false
    t.string "reviewer_username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.text "data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "state", limit: 1, default: 1, null: false
    t.index ["node_id"], name: "index_github_pull_requests_on_node_id", unique: true
  end

  create_table "github_tasks", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "uuid", null: false
    t.string "title", null: false
    t.string "repo", null: false
    t.string "issue_url", null: false
    t.string "opened_by_username"
    t.datetime "opened_at", null: false
    t.integer "action", limit: 1, default: 0
    t.integer "knowledge", limit: 1, default: 0
    t.integer "area", limit: 1, default: 0
    t.integer "size", limit: 1, default: 0
    t.integer "type", limit: 1, default: 0
    t.bigint "track_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_url"], name: "index_github_tasks_on_issue_url", unique: true
    t.index ["track_id"], name: "index_github_tasks_on_track_id"
    t.index ["uuid"], name: "index_github_tasks_on_uuid", unique: true
  end

  create_table "github_team_members", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "user_id", null: false
    t.string "team_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "team_name"], name: "index_github_team_members_on_user_id_and_team_name", unique: true
  end

  create_table "iterations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "solution_id", null: false
    t.bigint "submission_id", null: false
    t.string "uuid", null: false
    t.integer "idx", limit: 1, null: false
    t.string "snippet", limit: 1500
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "num_loc"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discussion_id"], name: "index_mentor_discussion_posts_on_discussion_id"
    t.index ["iteration_id"], name: "index_mentor_discussion_posts_on_iteration_id"
    t.index ["user_id"], name: "index_mentor_discussion_posts_on_user_id"
    t.index ["uuid"], name: "index_mentor_discussion_posts_on_uuid", unique: true
  end

  create_table "mentor_discussions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "uuid", null: false
    t.bigint "solution_id", null: false
    t.bigint "mentor_id", null: false
    t.bigint "request_id", null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.integer "rating", limit: 1
    t.integer "num_posts", limit: 3, default: 0, null: false
    t.boolean "anonymous_mode", default: false, null: false
    t.datetime "awaiting_student_since"
    t.datetime "awaiting_mentor_since"
    t.datetime "mentor_reminder_sent_at"
    t.datetime "finished_at"
    t.integer "finished_by", limit: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "external", default: false, null: false
    t.index ["mentor_id"], name: "index_mentor_discussions_on_mentor_id"
    t.index ["request_id"], name: "index_mentor_discussions_on_request_id"
    t.index ["solution_id"], name: "index_mentor_discussions_on_solution_id"
  end

  create_table "mentor_request_locks", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "request_id", null: false
    t.bigint "locked_by_id", null: false
    t.datetime "locked_until", null: false
    t.index ["request_id", "locked_by_id"], name: "index_mentor_request_locks_on_request_id_and_locked_by_id"
    t.index ["request_id"], name: "index_mentor_request_locks_on_request_id"
  end

  create_table "mentor_requests", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "uuid", null: false
    t.bigint "solution_id", null: false
    t.bigint "track_id", null: false
    t.bigint "exercise_id", null: false
    t.bigint "student_id", null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.text "comment_markdown", null: false
    t.text "comment_html", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "external", default: false, null: false
    t.index ["exercise_id", "status"], name: "index_mentor_requests_on_exercise_id_and_status"
    t.index ["exercise_id"], name: "index_mentor_requests_on_exercise_id"
    t.index ["solution_id"], name: "index_mentor_requests_on_solution_id"
    t.index ["status", "exercise_id"], name: "index_mentor_requests_on_status_and_exercise_id"
    t.index ["status", "track_id"], name: "index_mentor_requests_on_status_and_track_id"
    t.index ["student_id"], name: "index_mentor_requests_on_student_id"
    t.index ["track_id", "exercise_id"], name: "index_mentor_requests_on_track_id_and_exercise_id"
    t.index ["track_id", "status"], name: "index_mentor_requests_on_track_id_and_status"
    t.index ["track_id"], name: "index_mentor_requests_on_track_id"
    t.index ["uuid"], name: "index_mentor_requests_on_uuid", unique: true
  end

  create_table "mentor_student_relationships", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "mentor_id", null: false
    t.bigint "student_id", null: false
    t.boolean "favorited", default: false, null: false
    t.boolean "blocked_by_mentor", default: false, null: false
    t.boolean "blocked_by_student", default: false, null: false
    t.integer "num_discussions", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discussion_id"], name: "index_mentor_testimonials_on_discussion_id", unique: true
    t.index ["mentor_id"], name: "index_mentor_testimonials_on_mentor_id"
    t.index ["student_id"], name: "index_mentor_testimonials_on_student_id"
    t.index ["uuid"], name: "index_mentor_testimonials_on_uuid"
  end

  create_table "metric_period_days", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "day", limit: 1, default: 0, null: false
    t.string "metric_type", null: false
    t.bigint "track_id"
    t.integer "count", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["metric_type", "track_id", "day"], name: "uniq", unique: true
    t.index ["track_id"], name: "index_metric_period_days_on_track_id"
  end

  create_table "metric_period_minutes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "minute", limit: 2, default: 0, null: false
    t.string "metric_type", null: false
    t.bigint "track_id"
    t.integer "count", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["metric_type", "track_id", "minute"], name: "uniq", unique: true
    t.index ["track_id"], name: "index_metric_period_minutes_on_track_id"
  end

  create_table "metric_period_months", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "month", limit: 1, default: 0, null: false
    t.string "metric_type", null: false
    t.bigint "track_id"
    t.integer "count", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["metric_type", "track_id", "month"], name: "uniq", unique: true
    t.index ["track_id"], name: "index_metric_period_months_on_track_id"
  end

  create_table "metrics", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "type", null: false
    t.text "params", null: false
    t.bigint "track_id"
    t.bigint "user_id"
    t.string "uniqueness_key", null: false
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "country_code", limit: 2
    t.string "coordinates"
    t.index ["track_id"], name: "index_metrics_on_track_id"
    t.index ["type", "track_id", "occurred_at"], name: "index_metrics_on_type_and_track_id_and_occurred_at"
    t.index ["uniqueness_key"], name: "index_metrics_on_uniqueness_key", unique: true
    t.index ["user_id"], name: "index_metrics_on_user_id"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["about_type", "about_id"], name: "index_scratchpad_pages_on_about"
    t.index ["user_id"], name: "index_scratchpad_pages_on_user_id"
  end

  create_table "site_updates", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "type", null: false
    t.string "uniqueness_key", null: false
    t.text "params", null: false
    t.integer "version", null: false
    t.text "rendering_data_cache", null: false
    t.bigint "track_id"
    t.bigint "exercise_id"
    t.bigint "author_id"
    t.bigint "pull_request_id"
    t.datetime "published_at", null: false
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_site_updates_on_author_id"
    t.index ["exercise_id"], name: "index_site_updates_on_exercise_id"
    t.index ["pull_request_id"], name: "index_site_updates_on_pull_request_id"
    t.index ["track_id"], name: "index_site_updates_on_track_id"
    t.index ["uniqueness_key"], name: "index_site_updates_on_uniqueness_key", unique: true
  end

  create_table "solution_comments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "uuid", null: false
    t.bigint "solution_id", null: false
    t.bigint "user_id", null: false
    t.text "content_markdown", null: false
    t.text "content_html", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["solution_id"], name: "index_solution_comments_on_solution_id"
    t.index ["user_id"], name: "index_solution_comments_on_user_id"
    t.index ["uuid"], name: "index_solution_comments_on_uuid", unique: true
  end

  create_table "solution_stars", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "solution_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["solution_id", "user_id"], name: "index_solution_stars_on_solution_id_and_user_id", unique: true
    t.index ["solution_id"], name: "index_solution_stars_on_solution_id"
    t.index ["user_id"], name: "index_solution_stars_on_user_id"
  end

  create_table "solutions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "type", null: false
    t.string "unique_key", null: false
    t.bigint "user_id", null: false
    t.bigint "exercise_id", null: false
    t.bigint "published_iteration_id"
    t.string "uuid", null: false
    t.string "public_uuid", null: false
    t.string "git_slug", null: false
    t.string "git_sha", null: false
    t.string "git_important_files_hash", null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.string "iteration_status"
    t.boolean "allow_comments", default: true, null: false
    t.datetime "last_iterated_at"
    t.integer "num_iterations", limit: 1, default: 0, null: false
    t.string "snippet", limit: 1500
    t.datetime "downloaded_at"
    t.datetime "completed_at"
    t.datetime "published_at"
    t.integer "mentoring_status", limit: 1, default: 0, null: false
    t.integer "num_views", limit: 3, default: 0, null: false
    t.integer "num_stars", limit: 3, default: 0, null: false
    t.integer "num_comments", limit: 3, default: 0, null: false
    t.integer "num_loc", limit: 3
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "published_iteration_head_tests_status", default: 0, null: false
    t.integer "latest_iteration_head_tests_status", limit: 1, default: 0, null: false
    t.boolean "unlocked_help", default: false, null: false
    t.index ["exercise_id", "published_at"], name: "index_solutions_on_exercise_id_and_published_at"
    t.index ["exercise_id"], name: "index_solutions_on_exercise_id"
    t.index ["num_stars", "id"], name: "solutions_popular_new", order: :desc
    t.index ["public_uuid"], name: "index_solutions_on_public_uuid", unique: true
    t.index ["published_iteration_id"], name: "index_solutions_on_published_iteration_id"
    t.index ["unique_key"], name: "index_solutions_on_unique_key", unique: true
    t.index ["user_id"], name: "index_solutions_on_user_id"
    t.index ["uuid"], name: "index_solutions_on_uuid", unique: true
  end

  create_table "streaming_events", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.string "youtube_id"
    t.boolean "featured", default: false, null: false
    t.string "thumbnail_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["starts_at", "ends_at"], name: "index_streaming_events_on_starts_at_and_ends_at"
  end

  create_table "submission_analyses", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "submission_id", null: false
    t.integer "ops_status", limit: 2, null: false
    t.text "data"
    t.string "tooling_job_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "num_comments", limit: 1, default: 0, null: false
    t.bigint "track_id"
    t.index ["submission_id"], name: "index_submission_analyses_on_submission_id"
    t.index ["track_id", "id"], name: "index_submission_analyses_on_track_id_and_id", order: { id: :desc }
    t.index ["track_id", "num_comments"], name: "index_submission_analyses_on_track_id_and_num_comments"
    t.index ["track_id"], name: "index_submission_analyses_on_track_id"
  end

  create_table "submission_files", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "submission_id", null: false
    t.string "filename", null: false
    t.string "digest", null: false
    t.string "uri", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["submission_id"], name: "index_submission_files_on_submission_id"
  end

  create_table "submission_representations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "submission_id", null: false
    t.string "tooling_job_id", null: false
    t.integer "ops_status", limit: 2, null: false
    t.text "ast"
    t.string "ast_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "mentored_by_id"
    t.bigint "track_id"
    t.index ["mentored_by_id"], name: "index_submission_representations_on_mentored_by_id"
    t.index ["submission_id", "ast_digest"], name: "index_submission_representations_on_submission_id_and_ast_digest"
    t.index ["submission_id"], name: "index_submission_representations_on_submission_id"
    t.index ["track_id", "id"], name: "index_submission_representations_on_track_id_and_id", order: { id: :desc }
    t.index ["track_id"], name: "index_submission_representations_on_track_id"
  end

  create_table "submission_test_runs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "uuid", null: false
    t.bigint "submission_id", null: false
    t.string "tooling_job_id", null: false
    t.string "status", null: false
    t.text "message"
    t.integer "ops_status", limit: 2, null: false
    t.text "raw_results", size: :medium, null: false
    t.integer "version", limit: 1, default: 0, null: false
    t.text "output"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "git_important_files_hash", limit: 50
    t.string "git_sha", limit: 50
    t.bigint "track_id"
    t.index ["submission_id"], name: "index_submission_test_runs_on_submission_id"
    t.index ["track_id", "id"], name: "index_submission_test_runs_on_track_id_and_id", order: { id: :desc }
    t.index ["track_id"], name: "index_submission_test_runs_on_track_id"
    t.index ["uuid"], name: "index_submission_test_runs_on_uuid", unique: true
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "git_important_files_hash", limit: 50
    t.integer "track_id", limit: 2
    t.integer "exercise_id", limit: 3
    t.index ["solution_id"], name: "index_submissions_on_solution_id"
    t.index ["track_id", "exercise_id"], name: "index_submissions_on_track_id_and_exercise_id"
    t.index ["track_id", "tests_status"], name: "index_submissions_on_track_id_and_tests_status"
    t.index ["track_id"], name: "index_submissions_on_track_id"
    t.index ["uuid"], name: "index_submissions_on_uuid", unique: true
  end

  create_table "track_concept_authorships", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "track_concept_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["track_concept_id", "user_id"], name: "index_concept_authorships_concept_id_user_id", unique: true
    t.index ["track_concept_id"], name: "index_track_concept_authorships_on_track_concept_id"
    t.index ["user_id"], name: "index_track_concept_authorships_on_user_id"
  end

  create_table "track_concept_contributorships", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "track_concept_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["track_concept_id", "user_id"], name: "index_concept_contributorships_concept_id_user_id", unique: true
    t.index ["track_concept_id"], name: "index_track_concept_contributorships_on_track_concept_id"
    t.index ["user_id"], name: "index_track_concept_contributorships_on_user_id"
  end

  create_table "track_concepts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "track_id", null: false
    t.string "slug", null: false
    t.string "uuid", null: false
    t.string "name", null: false
    t.string "blurb", limit: 350, null: false
    t.string "synced_to_git_sha", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.integer "num_students", default: 0, null: false
    t.integer "median_wait_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "course", default: false, null: false
    t.boolean "has_test_runner", default: false, null: false
    t.boolean "has_representer", default: false, null: false
    t.boolean "has_analyzer", default: false, null: false
    t.integer "representer_version", limit: 2, default: 1, null: false
    t.string "intro_video_youtube_slug"
    t.index ["slug"], name: "index_tracks_on_slug", unique: true
  end

  create_table "user_acquired_badges", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "uuid", null: false
    t.bigint "user_id", null: false
    t.bigint "badge_id", null: false
    t.boolean "revealed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.text "params", null: false
    t.datetime "occurred_at", null: false
    t.string "uniqueness_key", null: false
    t.integer "version", null: false
    t.text "rendering_data_cache", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_user_auth_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_user_auth_tokens_on_user_id"
  end

  create_table "user_block_domains", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "domain", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domain"], name: "index_user_block_domains_on_domain", unique: true
  end

  create_table "user_challenges", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "challenge_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "challenge_id"], name: "index_user_challenges_on_user_id_and_challenge_id", unique: true
    t.index ["user_id"], name: "index_user_challenges_on_user_id"
  end

  create_table "user_communication_preferences", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token"
    t.boolean "email_on_mentor_started_discussion_notification", default: true, null: false
    t.boolean "email_on_mentor_replied_to_discussion_notification", default: true, null: false
    t.boolean "email_on_student_replied_to_discussion_notification", default: true, null: false
    t.boolean "email_on_student_added_iteration_notification", default: true, null: false
    t.boolean "email_on_new_solution_comment_for_solution_user_notification", default: true, null: false
    t.boolean "email_on_new_solution_comment_for_other_commenter_notification", default: true, null: false
    t.boolean "receive_product_updates", default: true, null: false
    t.boolean "email_on_remind_mentor", default: true, null: false
    t.boolean "email_on_mentor_heartbeat", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "email_on_general_update_notification", default: true, null: false
    t.boolean "email_on_acquired_badge_notification", default: true, null: false
    t.boolean "email_on_nudge_notification", default: true, null: false
    t.boolean "email_on_student_finished_discussion_notification", default: true, null: false
    t.boolean "email_on_mentor_finished_discussion_notification", default: true, null: false
    t.boolean "email_on_automated_feedback_added_notification", default: true, null: false
    t.boolean "email_about_fundraising_campaigns", default: true, null: false
    t.boolean "email_about_events", default: true, null: false
    t.index ["token"], name: "index_user_communication_preferences_on_token", unique: true
    t.index ["user_id"], name: "index_user_communication_preferences_on_user_id"
  end

  create_table "user_dismissed_introducers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "slug"], name: "index_user_dismissed_introducers_on_user_id_and_slug", unique: true
    t.index ["user_id"], name: "index_user_dismissed_introducers_on_user_id"
  end

  create_table "user_mailshots", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "mailshot_id", null: false
    t.integer "email_status", limit: 1, default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_status"], name: "index_user_mailshots_on_email_status"
    t.index ["user_id", "mailshot_id"], name: "index_user_mailshots_on_user_id_and_mailshot_id", unique: true
    t.index ["user_id"], name: "index_user_mailshots_on_user_id"
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
    t.text "params", null: false
    t.integer "email_status", limit: 1, default: 0, null: false
    t.string "uniqueness_key", null: false
    t.text "rendering_data_cache", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id"], name: "index_user_notifications_on_exercise_id"
    t.index ["track_id"], name: "index_user_notifications_on_track_id"
    t.index ["type", "user_id"], name: "index_user_notifications_on_type_and_user_id"
    t.index ["uniqueness_key"], name: "index_user_notifications_on_uniqueness_key", unique: true
    t.index ["user_id"], name: "index_user_notifications_on_user_id"
    t.index ["uuid"], name: "index_user_notifications_on_uuid", unique: true
  end

  create_table "user_preferences", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.boolean "auto_update_exercises", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_preferences_on_user_id", unique: true
  end

  create_table "user_profiles", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "twitter"
    t.string "website"
    t.string "github"
    t.string "linkedin"
    t.string "medium"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_profiles_on_user_id", unique: true
  end

  create_table "user_reputation_periods", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "track_id", null: false
    t.integer "about", limit: 1, null: false
    t.integer "period", limit: 1, null: false
    t.integer "category", limit: 1, null: false
    t.integer "reputation", default: 0, null: false
    t.string "user_handle"
    t.boolean "dirty", default: true, null: false
    t.index ["dirty"], name: "sweeper"
    t.index ["period", "category", "about", "reputation"], name: "search-2"
    t.index ["period", "category", "about", "track_id", "reputation"], name: "search-1"
    t.index ["period", "category", "about", "track_id", "user_handle", "reputation"], name: "search-3"
    t.index ["user_id", "period", "category", "about", "track_id"], name: "unique", unique: true
    t.index ["user_id"], name: "index_user_reputation_periods_on_user_id"
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
    t.text "params", null: false
    t.string "level"
    t.integer "version", null: false
    t.text "rendering_data_cache", null: false
    t.string "external_url"
    t.boolean "seen", default: false, null: false
    t.date "earned_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["earned_on"], name: "sweeper"
    t.index ["exercise_id"], name: "index_user_reputation_tokens_on_exercise_id"
    t.index ["track_id", "category", "external_url"], name: "index_user_reputation_tokens_on_track_id_category_external_url"
    t.index ["track_id"], name: "index_user_reputation_tokens_on_track_id"
    t.index ["uniqueness_key", "user_id"], name: "index_user_reputation_tokens_on_uniqueness_key_and_user_id", unique: true
    t.index ["user_id", "earned_on", "type"], name: "index_user_reputation_tokens_query_3"
    t.index ["user_id", "track_id", "earned_on", "type"], name: "index_user_reputation_tokens_query_4"
    t.index ["user_id", "track_id", "type"], name: "index_user_reputation_tokens_query_2"
    t.index ["user_id", "type"], name: "index_user_reputation_tokens_query_1"
    t.index ["user_id"], name: "index_user_reputation_tokens_on_user_id"
    t.index ["uuid"], name: "index_user_reputation_tokens_on_uuid", unique: true
  end

  create_table "user_track_mentorships", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "track_id", null: false
    t.boolean "last_viewed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "num_finished_discussions", limit: 3, default: 0, null: false
    t.index ["track_id"], name: "index_user_track_mentorships_on_track_id"
    t.index ["user_id", "track_id"], name: "index_user_track_mentorships_on_user_id_and_track_id", unique: true
    t.index ["user_id"], name: "index_user_track_mentorships_on_user_id"
  end

  create_table "user_tracks", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "track_id", null: false
    t.text "summary_data", null: false
    t.string "summary_key"
    t.boolean "practice_mode", default: false, null: false
    t.boolean "anonymous_during_mentoring", default: false, null: false
    t.datetime "last_touched_at", null: false
    t.text "objectives"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "deleted_at"
    t.datetime "joined_research_at"
    t.string "github_username"
    t.integer "reputation", default: 0, null: false
    t.json "roles"
    t.text "bio"
    t.string "avatar_url"
    t.string "location"
    t.string "pronouns"
    t.integer "num_solutions_mentored", limit: 3, default: 0, null: false
    t.integer "mentor_satisfaction_percentage", limit: 1
    t.string "stripe_customer_id"
    t.integer "total_donated_in_cents", default: 0
    t.boolean "active_donation_subscription", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "show_on_supporters_page", default: true, null: false
    t.datetime "disabled_at"
    t.date "last_visited_on"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["github_username"], name: "index_users_on_github_username", unique: true
    t.index ["handle"], name: "index_users_on_handle", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["stripe_customer_id"], name: "index_users_on_stripe_customer_id", unique: true
    t.index ["total_donated_in_cents", "show_on_supporters_page"], name: "users-supporters-page"
    t.index ["unconfirmed_email"], name: "index_users_on_unconfirmed_email"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "blog_posts", "users", column: "author_id"
  add_foreign_key "cohort_memberships", "cohorts"
  add_foreign_key "cohort_memberships", "users"
  add_foreign_key "cohorts", "tracks"
  add_foreign_key "community_stories", "users", column: "interviewee_id"
  add_foreign_key "community_stories", "users", column: "interviewer_id"
  add_foreign_key "community_videos", "users", column: "author_id"
  add_foreign_key "community_videos", "users", column: "submitted_by_id"
  add_foreign_key "documents", "tracks"
  add_foreign_key "donations_payments", "donations_subscriptions", column: "subscription_id"
  add_foreign_key "donations_payments", "users"
  add_foreign_key "donations_subscriptions", "users"
  add_foreign_key "exercise_approach_authorships", "exercise_approaches"
  add_foreign_key "exercise_approach_authorships", "users"
  add_foreign_key "exercise_approach_contributorships", "exercise_approaches"
  add_foreign_key "exercise_approach_contributorships", "users"
  add_foreign_key "exercise_approach_introduction_authorships", "exercises"
  add_foreign_key "exercise_approach_introduction_authorships", "users"
  add_foreign_key "exercise_approach_introduction_contributorships", "exercises"
  add_foreign_key "exercise_approach_introduction_contributorships", "users"
  add_foreign_key "exercise_approaches", "exercises"
  add_foreign_key "exercise_article_authorships", "exercise_articles"
  add_foreign_key "exercise_article_authorships", "users"
  add_foreign_key "exercise_article_contributorships", "exercise_articles"
  add_foreign_key "exercise_article_contributorships", "users"
  add_foreign_key "exercise_articles", "exercises"
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
  add_foreign_key "exercise_representations", "tracks"
  add_foreign_key "exercise_representations", "users", column: "feedback_author_id"
  add_foreign_key "exercise_representations", "users", column: "feedback_editor_id"
  add_foreign_key "exercise_taught_concepts", "exercises"
  add_foreign_key "exercise_taught_concepts", "track_concepts"
  add_foreign_key "exercises", "tracks"
  add_foreign_key "github_issue_labels", "github_issues"
  add_foreign_key "github_pull_request_reviews", "github_pull_requests"
  add_foreign_key "github_tasks", "tracks"
  add_foreign_key "iterations", "solutions"
  add_foreign_key "iterations", "submissions"
  add_foreign_key "mentor_discussion_posts", "iterations"
  add_foreign_key "mentor_discussion_posts", "mentor_discussions", column: "discussion_id"
  add_foreign_key "mentor_discussion_posts", "users"
  add_foreign_key "mentor_discussions", "mentor_requests", column: "request_id"
  add_foreign_key "mentor_discussions", "solutions"
  add_foreign_key "mentor_discussions", "users", column: "mentor_id"
  add_foreign_key "mentor_request_locks", "mentor_requests", column: "request_id"
  add_foreign_key "mentor_requests", "solutions"
  add_foreign_key "mentor_student_relationships", "users", column: "mentor_id"
  add_foreign_key "mentor_student_relationships", "users", column: "student_id"
  add_foreign_key "mentor_testimonials", "mentor_discussions", column: "discussion_id"
  add_foreign_key "mentor_testimonials", "users", column: "mentor_id"
  add_foreign_key "mentor_testimonials", "users", column: "student_id"
  add_foreign_key "problem_reports", "exercises"
  add_foreign_key "problem_reports", "tracks"
  add_foreign_key "problem_reports", "users"
  add_foreign_key "scratchpad_pages", "users"
  add_foreign_key "site_updates", "exercises"
  add_foreign_key "site_updates", "github_pull_requests", column: "pull_request_id"
  add_foreign_key "site_updates", "tracks"
  add_foreign_key "site_updates", "users", column: "author_id"
  add_foreign_key "solution_comments", "solutions"
  add_foreign_key "solution_comments", "users"
  add_foreign_key "solution_stars", "solutions"
  add_foreign_key "solution_stars", "users"
  add_foreign_key "solutions", "exercises"
  add_foreign_key "solutions", "iterations", column: "published_iteration_id"
  add_foreign_key "solutions", "users"
  add_foreign_key "submission_analyses", "submissions"
  add_foreign_key "submission_analyses", "tracks"
  add_foreign_key "submission_files", "submissions"
  add_foreign_key "submission_representations", "submissions"
  add_foreign_key "submission_representations", "tracks"
  add_foreign_key "submission_representations", "users", column: "mentored_by_id"
  add_foreign_key "submission_test_runs", "submissions"
  add_foreign_key "submission_test_runs", "tracks"
  add_foreign_key "submissions", "solutions"
  add_foreign_key "track_concept_authorships", "track_concepts"
  add_foreign_key "track_concept_authorships", "users"
  add_foreign_key "track_concept_contributorships", "track_concepts"
  add_foreign_key "track_concept_contributorships", "users"
  add_foreign_key "track_concepts", "tracks"
  add_foreign_key "user_acquired_badges", "badges"
  add_foreign_key "user_acquired_badges", "users"
  add_foreign_key "user_activities", "exercises"
  add_foreign_key "user_activities", "solutions"
  add_foreign_key "user_activities", "tracks"
  add_foreign_key "user_activities", "users"
  add_foreign_key "user_auth_tokens", "users"
  add_foreign_key "user_communication_preferences", "users"
  add_foreign_key "user_dismissed_introducers", "users"
  add_foreign_key "user_notifications", "exercises"
  add_foreign_key "user_notifications", "tracks"
  add_foreign_key "user_notifications", "users"
  add_foreign_key "user_preferences", "users"
  add_foreign_key "user_profiles", "users"
  add_foreign_key "user_reputation_periods", "users"
  add_foreign_key "user_reputation_tokens", "exercises"
  add_foreign_key "user_reputation_tokens", "tracks"
  add_foreign_key "user_reputation_tokens", "users"
  add_foreign_key "user_track_mentorships", "tracks"
  add_foreign_key "user_track_mentorships", "users"
  add_foreign_key "user_tracks", "tracks"
  add_foreign_key "user_tracks", "users"
end
