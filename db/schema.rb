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

ActiveRecord::Schema[7.0].define(version: 2024_02_01_170724) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
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
    t.string "uuid", null: false
    t.string "slug", null: false
    t.string "category", null: false
    t.datetime "published_at", precision: nil, null: false
    t.string "title", null: false
    t.string "marketing_copy", limit: 280
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "image_url"
    t.text "description"
    t.string "youtube_id"
    t.bigint "author_id", null: false
    t.index ["author_id"], name: "fk_rails_b88cda424b"
    t.index ["published_at"], name: "index_blog_posts_on_published_at"
    t.index ["slug"], name: "index_blog_posts_on_slug", unique: true
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
    t.datetime "published_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["author_id"], name: "index_community_videos_on_author_id"
    t.index ["exercise_id"], name: "index_community_videos_on_exercise_id"
    t.index ["published_at"], name: "index_community_videos_on_published_at"
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
    t.decimal "amount_in_cents", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "email_status", limit: 1, default: 0, null: false
    t.integer "provider", limit: 1, default: 0, null: false
    t.string "external_id", null: false
    t.string "external_receipt_url"
    t.integer "product", limit: 1, default: 0
    t.index ["external_id", "provider"], name: "index_donations_payments_on_external_id_and_provider", unique: true
    t.index ["subscription_id"], name: "index_donations_payments_on_subscription_id"
    t.index ["user_id"], name: "index_donations_payments_on_user_id"
  end

  create_table "donations_subscriptions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "amount_in_cents", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "email_status", limit: 1, default: 0, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.integer "provider", limit: 1, default: 0, null: false
    t.string "external_id", null: false
    t.integer "product", limit: 1, default: 0
    t.integer "interval", limit: 1, default: 0, null: false
    t.index ["external_id", "provider"], name: "index_donations_subscriptions_on_external_id_and_provider", unique: true
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
    t.json "tags"
    t.integer "num_solutions", default: 0, null: false
    t.integer "position", limit: 1, null: false
    t.index ["exercise_id", "position"], name: "index_exercise_approaches_on_exercise_id_and_position"
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
    t.integer "position", limit: 1, null: false
    t.index ["exercise_id", "position"], name: "index_exercise_articles_on_exercise_id_and_position"
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
    t.integer "num_submissions", limit: 3, default: 1, null: false
    t.datetime "last_submitted_at", default: -> { "CURRENT_TIMESTAMP(6)" }, null: false
    t.bigint "track_id"
    t.string "uuid"
    t.datetime "feedback_added_at"
    t.integer "representer_version", limit: 2, default: 1, null: false
    t.integer "exercise_version", limit: 2, default: 1, null: false
    t.integer "draft_feedback_type", limit: 1
    t.text "draft_feedback_markdown"
    t.string "exercise_id_and_ast_digest_idx_cache"
    t.integer "num_published_solutions", default: 0, null: false
    t.bigint "oldest_solution_id"
    t.bigint "prestigious_solution_id"
    t.index ["ast_digest"], name: "index_exercise_representations_on_ast_digest"
    t.index ["exercise_id", "ast_digest", "representer_version", "exercise_version"], name: "exercise_representations_guard", unique: true
    t.index ["exercise_id", "representer_version", "feedback_added_at"], name: "search_ex_4", order: { representer_version: :desc, feedback_added_at: :desc }
    t.index ["exercise_id", "representer_version", "feedback_added_at"], name: "search_ex_5", order: { representer_version: :desc }
    t.index ["exercise_id", "representer_version", "last_submitted_at"], name: "search_ex_3", order: { representer_version: :desc, last_submitted_at: :desc }
    t.index ["exercise_id", "representer_version", "num_submissions", "last_submitted_at"], name: "search_ex_2", order: { representer_version: :desc, last_submitted_at: :desc }
    t.index ["exercise_id", "representer_version", "num_submissions"], name: "search_ex_1", order: { representer_version: :desc }
    t.index ["exercise_id_and_ast_digest_idx_cache", "id"], name: "index_sub_rep"
    t.index ["feedback_author_id", "exercise_id", "last_submitted_at"], name: "index_exercise_representation_author_exercise_last_submitted_at"
    t.index ["feedback_author_id", "exercise_id", "num_submissions"], name: "index_exercise_representation_author_exercise_num_submissions"
    t.index ["feedback_author_id", "track_id", "last_submitted_at"], name: "index_exercise_representation_author_track_last_submitted_at"
    t.index ["feedback_author_id"], name: "index_exercise_representations_on_feedback_author_id"
    t.index ["feedback_editor_id"], name: "index_exercise_representations_on_feedback_editor_id"
    t.index ["feedback_type", "exercise_id", "last_submitted_at"], name: "index_exercise_representation_type_exercise_last_submitted_at"
    t.index ["feedback_type", "exercise_id", "num_submissions"], name: "index_exercise_representation_type_exercise_num_submissions"
    t.index ["feedback_type", "track_id", "last_submitted_at"], name: "index_exercise_representation_type_track_last_submitted_at"
    t.index ["feedback_type", "track_id", "num_submissions"], name: "index_exercise_representation_type_track_num_submissions"
    t.index ["source_submission_id"], name: "index_exercise_representations_on_source_submission_id"
    t.index ["track_id", "representer_version", "feedback_added_at"], name: "search_track_4", order: { representer_version: :desc, feedback_added_at: :desc }
    t.index ["track_id", "representer_version", "feedback_added_at"], name: "search_track_5", order: { representer_version: :desc }
    t.index ["track_id", "representer_version", "feedback_type", "num_submissions"], name: "search_track_2", order: { representer_version: :desc, num_submissions: :desc }
    t.index ["track_id", "representer_version", "last_submitted_at"], name: "search_track_3", order: { representer_version: :desc, last_submitted_at: :desc }
    t.index ["track_id", "representer_version", "num_submissions"], name: "search_track_1", order: { representer_version: :desc, num_submissions: :desc }
    t.index ["track_id", "representer_version"], name: "index_exercise_representations_track_version_desc", order: { representer_version: :desc }
    t.index ["track_id"], name: "index_exercise_representations_on_track_id"
    t.index ["uuid"], name: "index_exercise_representations_on_uuid", unique: true
  end

  create_table "exercise_tags", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "tag", null: false
    t.boolean "filterable", default: true, null: false
    t.bigint "exercise_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id", "tag"], name: "index_exercise_tags_on_exercise_id_and_tag", unique: true
    t.index ["exercise_id"], name: "index_exercise_tags_on_exercise_id"
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
    t.string "slug", null: false
    t.string "title", null: false
    t.text "blurb"
    t.integer "difficulty", default: 1, null: false
    t.integer "position"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "median_wait_time"
    t.integer "status", limit: 1, default: 2, null: false
    t.string "icon_name", null: false
    t.string "type", null: false
    t.string "git_sha", null: false
    t.string "synced_to_git_sha", null: false
    t.string "git_important_files_hash", null: false
    t.boolean "has_test_runner", default: false, null: false
    t.integer "num_published_solutions", default: 0, null: false
    t.boolean "has_approaches", default: false, null: false
    t.integer "representer_version", limit: 2, default: 1, null: false
    t.index ["track_id", "uuid"], name: "index_exercises_on_track_id_and_uuid", unique: true
    t.index ["track_id"], name: "fk_rails_a796d89c21"
  end

  create_table "friendly_id_slugs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "slug", limit: 190, null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope", limit: 190
    t.datetime "created_at", precision: nil
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "generic_exercises", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "slug", null: false
    t.string "title", null: false
    t.string "blurb", null: false
    t.string "source"
    t.string "source_url"
    t.string "deep_dive_youtube_id"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "deep_dive_blurb"
    t.index ["slug"], name: "index_generic_exercises_on_slug", unique: true
    t.index ["title"], name: "index_generic_exercises_on_title"
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
    t.datetime "opened_at", precision: nil, null: false
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
    t.datetime "opened_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "solution_type", default: "Solution", null: false
    t.string "legacy_uuid"
    t.bigint "submission_id", null: false
    t.string "uuid", null: false
    t.datetime "deleted_at", precision: nil
    t.integer "idx", limit: 1, null: false
    t.string "snippet", limit: 1500
    t.integer "num_loc"
    t.index ["solution_id"], name: "fk_rails_5d9f1bf4bd"
    t.index ["submission_id"], name: "index_iterations_on_submission_id", unique: true
    t.index ["uuid"], name: "iterations_uuid"
  end

  create_table "mailshots", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "slug", null: false
    t.string "email_communication_preferences_key", null: false
    t.boolean "test_sent", default: false, null: false
    t.json "sent_to_audiences"
    t.string "subject", null: false
    t.string "button_url", null: false
    t.string "button_text", null: false
    t.text "text_content", null: false
    t.text "content_markdown", null: false
    t.text "content_html", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_mailshots_on_slug", unique: true
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
    t.bigint "mentor_id", null: false
    t.bigint "solution_id", null: false
    t.integer "rating"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "awaiting_mentor_since", precision: nil
    t.datetime "mentor_reminder_sent_at", precision: nil
    t.string "uuid", null: false
    t.integer "num_posts", limit: 3, default: 0, null: false
    t.boolean "anonymous_mode", default: false, null: false
    t.datetime "awaiting_student_since", precision: nil
    t.bigint "request_id", null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.datetime "finished_at", precision: nil
    t.integer "finished_by", limit: 1
    t.boolean "external", default: false, null: false
    t.index ["mentor_id", "status"], name: "index_mentor_discussions_on_mentor_id_and_status"
    t.index ["request_id"], name: "fk_rails_38162d0a13"
    t.index ["solution_id"], name: "fk_rails_704ccdde73"
    t.index ["status", "awaiting_mentor_since"], name: "index_mentor_discussions_on_status_and_awaiting_mentor_since"
    t.index ["status", "awaiting_student_since"], name: "index_mentor_discussions_on_status_and_awaiting_student_since"
    t.index ["uuid"], name: "index_mentor_discussions_on_uuid", unique: true
  end

  create_table "mentor_request_locks", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "request_id", null: false
    t.bigint "locked_by_id", null: false
    t.datetime "locked_until", precision: nil, null: false
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
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discussion_id"], name: "index_mentor_testimonials_on_discussion_id", unique: true
    t.index ["mentor_id", "discussion_id"], name: "index_on_mentor_testimonials_track_lookup"
    t.index ["mentor_id", "revealed"], name: "index_mentor_testimonials_on_mentor_id_and_revealed"
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
    t.string "country_name"
    t.index ["track_id"], name: "index_metrics_on_track_id"
    t.index ["type", "track_id", "occurred_at"], name: "index_metrics_on_type_and_track_id_and_occurred_at"
    t.index ["uniqueness_key"], name: "index_metrics_on_uniqueness_key", unique: true
    t.index ["user_id"], name: "index_metrics_on_user_id"
  end

  create_table "partner_adverts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "uuid", null: false
    t.bigint "partner_id"
    t.integer "status", default: 0, null: false
    t.integer "num_impressions", default: 0, null: false
    t.integer "num_clicks", default: 0, null: false
    t.string "url", null: false
    t.string "base_text", null: false
    t.string "emphasised_text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["partner_id"], name: "index_partner_adverts_on_partner_id"
  end

  create_table "partner_perks", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "uuid", null: false
    t.bigint "partner_id"
    t.integer "status", default: 0, null: false
    t.integer "num_clicks", default: 0, null: false
    t.string "preview_text", null: false
    t.string "general_url", null: false
    t.string "general_offer_summary_markdown", null: false
    t.string "general_offer_summary_html", null: false
    t.string "general_button_text", null: false
    t.string "general_offer_details", null: false
    t.string "general_voucher_code"
    t.string "insiders_url"
    t.string "insiders_offer_summary_markdown"
    t.string "insiders_offer_summary_html"
    t.string "insiders_button_text"
    t.string "insiders_offer_details"
    t.string "insiders_voucher_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["partner_id"], name: "index_partner_perks_on_partner_id"
  end

  create_table "partners", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "headline"
    t.text "support_markdown"
    t.text "support_html"
    t.text "description_markdown", null: false
    t.text "description_html", null: false
    t.string "website_url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_partners_on_slug", unique: true
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

  create_table "research_experiment_solutions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "experiment_id", null: false
    t.string "uuid", null: false
    t.bigint "exercise_id", null: false
    t.string "git_sha", null: false
    t.string "git_slug", null: false
    t.datetime "started_at", precision: nil
    t.datetime "finished_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "difficulty_rating"
    t.index ["exercise_id"], name: "fk_rails_1be696c295"
    t.index ["experiment_id"], name: "fk_rails_8f6bde7fee"
    t.index ["user_id", "experiment_id", "exercise_id"], name: "research_solutions_uniq", unique: true
  end

  create_table "research_experiments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.string "repo_url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_research_experiments_on_slug"
  end

  create_table "research_user_experiments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "experiment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "survey"
    t.index ["experiment_id"], name: "fk_rails_809b029224"
    t.index ["user_id", "experiment_id"], name: "index_research_user_experiments_on_user_id_and_experiment_id", unique: true
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

  create_table "site_tags", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "tag", null: false
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag"], name: "index_site_tags_on_tag", unique: true
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
    t.datetime "published_at", precision: nil, null: false
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description_markdown"
    t.text "description_html"
    t.index ["author_id"], name: "index_site_updates_on_author_id"
    t.index ["exercise_id"], name: "index_site_updates_on_exercise_id"
    t.index ["pull_request_id"], name: "index_site_updates_on_pull_request_id"
    t.index ["track_id", "published_at", "id"], name: "index_site_updates_on_track_id_and_published_at_and_id"
    t.index ["track_id"], name: "index_site_updates_on_track_id"
    t.index ["uniqueness_key"], name: "index_site_updates_on_uniqueness_key", unique: true
  end

  create_table "solution_comments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "solution_id", null: false
    t.bigint "user_id", null: false
    t.text "content_markdown", size: :long, null: false
    t.text "content_html", size: :long, null: false
    t.boolean "edited", default: false, null: false
    t.text "previous_content"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "uuid", null: false
    t.index ["solution_id"], name: "fk_rails_f34a457d42"
    t.index ["user_id"], name: "index_solution_comments_on_user_id"
    t.index ["uuid"], name: "index_solution_comments_on_uuid", unique: true
  end

  create_table "solution_stars", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "solution_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["solution_id", "user_id"], name: "index_solution_stars_on_solution_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_solution_stars_on_user_id"
  end

  create_table "solution_tags", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "tag", null: false
    t.bigint "solution_id", null: false
    t.bigint "exercise_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "track_id", null: false
    t.index ["exercise_id"], name: "index_solution_tags_on_exercise_id"
    t.index ["solution_id", "tag"], name: "index_solution_tags_on_solution_id_and_tag", unique: true
    t.index ["solution_id"], name: "index_solution_tags_on_solution_id"
    t.index ["user_id"], name: "index_solution_tags_on_user_id"
  end

  create_table "solutions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "uuid", null: false
    t.bigint "exercise_id", null: false
    t.string "git_sha", null: false
    t.string "git_slug", null: false
    t.bigint "approved_by_id"
    t.datetime "downloaded_at", precision: nil
    t.datetime "completed_at", precision: nil
    t.datetime "published_at", precision: nil
    t.integer "num_reactions", default: 0, null: false
    t.text "reflection"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "mentoring_requested_at", precision: nil
    t.boolean "show_on_profile", default: false, null: false
    t.boolean "allow_comments", default: false, null: false
    t.integer "num_comments", limit: 2, default: 0, null: false
    t.integer "num_stars", limit: 2, default: 0, null: false
    t.integer "num_views", limit: 3, default: 0, null: false
    t.integer "num_loc", limit: 3
    t.bigint "published_iteration_id"
    t.integer "status", limit: 1, default: 0, null: false
    t.string "iteration_status"
    t.integer "mentoring_status", limit: 1, default: 0, null: false
    t.string "snippet", limit: 1500
    t.integer "num_iterations", limit: 1, default: 0, null: false
    t.string "type", null: false
    t.string "public_uuid", null: false
    t.datetime "last_iterated_at", precision: nil
    t.string "git_important_files_hash", null: false
    t.string "unique_key", null: false
    t.integer "published_iteration_head_tests_status", default: 0, null: false
    t.integer "latest_iteration_head_tests_status", limit: 1, default: 0, null: false
    t.boolean "unlocked_help", default: false, null: false
    t.bigint "published_exercise_representation_id"
    t.bigint "exercise_approach_id"
    t.index ["approved_by_id"], name: "fk_rails_4cc89d0b11"
    t.index ["created_at", "exercise_id"], name: "mentor_selection_idx_1"
    t.index ["created_at", "exercise_id"], name: "mentor_selection_idx_2"
    t.index ["exercise_approach_id"], name: "index_solutions_on_exercise_approach_id"
    t.index ["exercise_id", "approved_by_id", "completed_at", "mentoring_requested_at", "id"], name: "mentor_selection_idx_3"
    t.index ["exercise_id", "git_important_files_hash"], name: "index_solutions_on_exercise_id_and_git_important_files_hash"
    t.index ["exercise_id", "status", "num_stars", "updated_at"], name: "solutions_ex_stat_stars_upat"
    t.index ["exercise_id", "status", "published_iteration_head_tests_status", "id"], name: "index_other_comm_solutions"
    t.index ["exercise_id", "status", "published_iteration_head_tests_status"], name: "index_solutions_other_solutions"
    t.index ["exercise_id"], name: "fk_rails_8c0841e614"
    t.index ["num_stars", "id"], name: "solutions_popular_new"
    t.index ["public_uuid"], name: "solutions_public_uuid"
    t.index ["published_exercise_representation_id"], name: "fk_rails_3d3fa40f89"
    t.index ["published_iteration_id"], name: "fk_rails_16788386df"
    t.index ["unique_key"], name: "index_solutions_on_unique_key", unique: true
    t.index ["user_id", "exercise_id"], name: "index_solutions_on_user_id_and_exercise_id"
    t.index ["user_id", "status", "exercise_id"], name: "index_solutions_on_user_id_and_status_and_exercise_id"
    t.index ["user_id", "status"], name: "index_solutions_on_user_id_and_status"
    t.index ["uuid"], name: "index_solutions_on_uuid"
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

  create_table "submission_ai_help_records", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "submission_id", null: false
    t.string "source", null: false
    t.text "advice_markdown", null: false
    t.text "advice_html", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["submission_id"], name: "fk_rails_76b9473637"
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
    t.text "tags_data"
    t.index ["submission_id"], name: "index_submission_analyses_on_submission_id"
    t.index ["track_id", "id"], name: "index_submission_analyses_on_track_id_and_id"
    t.index ["track_id", "num_comments"], name: "index_submission_analyses_on_track_id_and_num_comments"
    t.index ["track_id"], name: "index_submission_analyses_on_track_id"
  end

  create_table "submission_files", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "submission_id", null: false
    t.string "filename", null: false
    t.binary "file_contents"
    t.text "digest", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "uri", null: false
    t.index ["submission_id"], name: "fk_rails_d1aca45f2f"
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
    t.bigint "mentor_id"
    t.bigint "track_id"
    t.string "exercise_id_and_ast_digest_idx_cache"
    t.integer "exercise_representer_version", limit: 2, default: 1, null: false
    t.index ["ast_digest"], name: "index_submission_representations_on_ast_digest"
    t.index ["exercise_id_and_ast_digest_idx_cache"], name: "index_ex_rep"
    t.index ["mentor_id"], name: "index_submission_representations_on_mentor_id"
    t.index ["mentored_by_id"], name: "index_submission_representations_on_mentored_by_id"
    t.index ["submission_id", "ast_digest"], name: "index_submission_representations_on_submission_id_and_ast_digest"
    t.index ["submission_id"], name: "index_submission_representations_on_submission_id"
    t.index ["track_id", "id"], name: "index_submission_representations_on_track_id_and_id"
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
    t.integer "track_id", limit: 2
    t.index ["git_important_files_hash", "submission_id"], name: "submissions-test-runs-git-optimiser-2"
    t.index ["git_sha", "submission_id"], name: "submissions-test-runs-git-optimiser-1"
    t.index ["submission_id", "git_important_files_hash"], name: "index_submission_test_run_on_submission_id_and_gifh"
    t.index ["submission_id", "git_sha"], name: "submissions-test-runs-git-optimiser-3"
    t.index ["submission_id"], name: "index_submission_test_runs_on_submission_id"
    t.index ["track_id", "id"], name: "index_submission_test_runs_on_track_id_and_id"
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
    t.integer "exercise_representer_version", limit: 2, default: 1, null: false
    t.bigint "approach_id"
    t.json "tags"
    t.index ["approach_id"], name: "index_submissions_on_approach_id"
    t.index ["exercise_id", "git_important_files_hash"], name: "index_submissions_on_exercise_id_and_git_important_files_hash"
    t.index ["git_important_files_hash", "solution_id"], name: "submissions-git-optimiser-2"
    t.index ["git_sha", "solution_id", "git_important_files_hash"], name: "submissions-git-optimiser-1"
    t.index ["solution_id"], name: "index_submissions_on_solution_id"
    t.index ["track_id", "exercise_id"], name: "index_submissions_on_track_id_and_exercise_id"
    t.index ["track_id", "tests_status"], name: "index_submissions_on_track_id_and_tests_status"
    t.index ["track_id"], name: "index_submissions_on_track_id"
    t.index ["uuid"], name: "index_submissions_on_uuid", unique: true
  end

  create_table "team_invitations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "invited_by_id", null: false
    t.string "email", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "token", null: false
    t.index ["invited_by_id"], name: "fk_rails_654806c772"
    t.index ["team_id", "email"], name: "index_team_invitations_on_team_id_and_email", unique: true
  end

  create_table "team_memberships", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "user_id", null: false
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["team_id", "user_id"], name: "index_team_memberships_on_team_id_and_user_id", unique: true
    t.index ["team_id"], name: "fk_rails_61c29b529e"
    t.index ["user_id"], name: "fk_rails_5aba9331a7"
  end

  create_table "team_solutions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "team_id", null: false
    t.string "uuid", null: false
    t.bigint "exercise_id", null: false
    t.string "git_sha", null: false
    t.string "git_slug", null: false
    t.boolean "needs_feedback", default: false, null: false
    t.boolean "has_unseen_feedback", default: false, null: false
    t.integer "num_iterations", default: 0, null: false
    t.datetime "downloaded_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["exercise_id"], name: "fk_rails_ba74ecfdce"
    t.index ["team_id"], name: "fk_rails_1c8d2e5b15"
    t.index ["user_id", "team_id", "exercise_id"], name: "index_team_solutions_on_user_id_and_team_id_and_exercise_id", unique: true
  end

  create_table "teams", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "description"
    t.string "token", null: false
    t.boolean "url_join_allowed", default: true, null: false
    t.index ["slug"], name: "index_teams_on_slug", unique: true
    t.index ["token"], name: "index_teams_on_token", unique: true
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

  create_table "track_tags", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "track_id", null: false
    t.string "tag", null: false
    t.boolean "enabled", default: true, null: false
    t.boolean "filterable", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "track_trophies", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "type", null: false
    t.json "valid_track_slugs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "num_awardees", limit: 3, default: 0, null: false
    t.index ["type"], name: "index_track_trophies_on_type", unique: true
  end

  create_table "tracks", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "slug", null: false
    t.string "title", null: false
    t.string "repo_url", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "active", default: true, null: false
    t.integer "median_wait_time"
    t.string "blurb", limit: 400, null: false
    t.string "synced_to_git_sha", null: false
    t.json "tags"
    t.integer "num_exercises", limit: 3, default: 0, null: false
    t.integer "num_concepts", limit: 3, default: 0, null: false
    t.integer "num_students", default: 0, null: false
    t.boolean "course", default: false, null: false
    t.boolean "has_test_runner", default: false, null: false
    t.boolean "has_representer", default: false, null: false
    t.boolean "has_analyzer", default: false, null: false
    t.integer "representer_version", limit: 2, default: 1, null: false
    t.string "intro_video_youtube_slug"
    t.string "highlightjs_language"
    t.index ["active"], name: "index_tracks_on_active"
    t.index ["slug"], name: "index_tracks_on_slug", unique: true
  end

  create_table "training_data_code_tags_samples", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "track_id", null: false
    t.bigint "exercise_id"
    t.bigint "solution_id"
    t.integer "status", default: 0, null: false
    t.integer "dataset", default: 0, null: false
    t.text "tags"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uuid", null: false
    t.text "files", null: false
    t.datetime "locked_until"
    t.bigint "locked_by_id"
    t.text "llm_tags"
    t.index ["exercise_id"], name: "index_training_data_code_tags_samples_on_exercise_id"
    t.index ["solution_id"], name: "index_training_data_code_tags_samples_on_solution_id"
    t.index ["track_id"], name: "index_training_data_code_tags_samples_on_track_id"
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
    t.datetime "occurred_at", precision: nil, null: false
    t.string "uniqueness_key", null: false
    t.integer "version", null: false
    t.text "rendering_data_cache", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id"], name: "index_user_activities_on_exercise_id"
    t.index ["solution_id"], name: "index_user_activities_on_solution_id"
    t.index ["track_id"], name: "index_user_activities_on_track_id"
    t.index ["uniqueness_key"], name: "index_user_activities_on_uniqueness_key", unique: true
    t.index ["user_id", "track_id", "solution_id"], name: "index_user_activities_on_user_id_and_track_id_and_solution_id"
    t.index ["user_id", "track_id"], name: "index_user_activities_on_user_id_and_track_id"
    t.index ["user_id"], name: "index_user_activities_on_user_id"
  end

  create_table "user_auth_tokens", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "active", default: true, null: false
    t.index ["token"], name: "index_user_auth_tokens_on_token", unique: true
    t.index ["user_id", "active"], name: "index_user_auth_tokens_on_user_id_and_active"
    t.index ["user_id"], name: "fk_rails_0d66c22f4c"
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
    t.boolean "email_on_mentor_replied_to_discussion_notification", default: true, null: false
    t.boolean "email_on_student_replied_to_discussion_notification", default: true, null: false
    t.boolean "email_on_student_added_iteration_notification", default: true, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "receive_product_updates", default: true, null: false
    t.boolean "email_on_remind_mentor", default: true, null: false
    t.boolean "email_on_new_solution_comment_for_solution_user_notification", default: true, null: false
    t.boolean "email_on_new_solution_comment_for_other_commenter_notification", default: true, null: false
    t.boolean "email_on_mentor_heartbeat", default: true, null: false
    t.string "token"
    t.boolean "email_on_remind_about_solution", default: true, null: false
    t.boolean "email_on_mentor_started_discussion_notification", default: true, null: false
    t.boolean "email_on_general_update_notification", default: true, null: false
    t.boolean "email_on_acquired_badge_notification", default: true, null: false
    t.boolean "email_on_nudge_notification", default: true, null: false
    t.boolean "email_on_student_finished_discussion_notification", default: true, null: false
    t.boolean "email_on_mentor_finished_discussion_notification", default: true, null: false
    t.boolean "email_on_automated_feedback_added_notification", default: true, null: false
    t.boolean "email_about_fundraising_campaigns", default: true, null: false
    t.boolean "email_about_events", default: true, null: false
    t.boolean "email_about_insiders", default: true, null: false
    t.boolean "email_on_acquired_trophy_notification", default: true, null: false
    t.boolean "email_on_nudge_student_to_reply_in_discussion_notification", default: true, null: false
    t.boolean "email_on_nudge_mentor_to_reply_in_discussion_notification", default: true, null: false
    t.boolean "email_on_mentor_timed_out_discussion_notification", default: true, null: false
    t.boolean "email_on_student_timed_out_discussion_notification", default: true, null: false
    t.boolean "receive_onboarding_emails", default: true, null: false
    t.index ["token"], name: "index_user_communication_preferences_on_token"
    t.index ["user_id"], name: "fk_rails_65642a5510"
  end

  create_table "user_data", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "bio"
    t.json "roles"
    t.json "usages"
    t.integer "insiders_status", limit: 1, default: 0, null: false
    t.string "github_username"
    t.string "stripe_customer_id"
    t.string "paypal_payer_id"
    t.string "discord_uid"
    t.datetime "accepted_privacy_policy_at"
    t.datetime "accepted_terms_at"
    t.datetime "became_mentor_at"
    t.datetime "joined_research_at"
    t.datetime "first_donated_at"
    t.date "last_visited_on"
    t.integer "num_solutions_mentored", limit: 3, default: 0, null: false
    t.integer "mentor_satisfaction_percentage", limit: 1
    t.integer "total_donated_in_cents", default: 0
    t.boolean "show_on_supporters_page", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "cache"
    t.integer "email_status", limit: 1, default: 0, null: false
    t.datetime "premium_until"
    t.boolean "trainer", default: false, null: false
    t.index ["discord_uid"], name: "index_user_data_on_discord_uid", unique: true
    t.index ["first_donated_at", "show_on_supporters_page", "user_id"], name: "index_user_data__supporters-page"
    t.index ["first_donated_at"], name: "index_user_data_on_first_donated_at"
    t.index ["github_username"], name: "index_user_data_on_github_username", unique: true
    t.index ["insiders_status"], name: "index_user_data_on_insiders_status"
    t.index ["last_visited_on"], name: "index_user_data_on_last_visited_on"
    t.index ["paypal_payer_id"], name: "index_user_data_on_paypal_payer_id", unique: true
    t.index ["premium_until"], name: "index_user_data_on_premium_until"
    t.index ["show_on_supporters_page", "first_donated_at", "user_id"], name: "index_user_data_supporters-page"
    t.index ["stripe_customer_id"], name: "index_user_data_on_stripe_customer_id", unique: true
    t.index ["user_id"], name: "index_user_data_on_user_id", unique: true
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
    t.string "mailshot_slug"
    t.integer "email_status", limit: 1, default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "mailshot_id", null: false
    t.index ["email_status"], name: "index_user_mailshots_on_email_status"
    t.index ["mailshot_id"], name: "fk_rails_9ddeeadfc0"
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
    t.datetime "read_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id"], name: "index_user_notifications_on_exercise_id"
    t.index ["track_id"], name: "index_user_notifications_on_track_id"
    t.index ["type", "user_id"], name: "index_user_notifications_on_type_and_user_id"
    t.index ["uniqueness_key"], name: "index_user_notifications_on_uniqueness_key", unique: true
    t.index ["user_id", "status"], name: "index_user_notifications_on_user_id_and_status"
    t.index ["user_id"], name: "index_user_notifications_on_user_id"
    t.index ["uuid"], name: "index_user_notifications_on_uuid", unique: true
  end

  create_table "user_preferences", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.boolean "auto_update_exercises", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "theme"
    t.boolean "allow_comments_on_published_solutions", default: false, null: false
    t.index ["user_id"], name: "index_user_preferences_on_user_id", unique: true
  end

  create_table "user_profiles", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "display_name"
    t.string "twitter"
    t.string "website"
    t.string "github"
    t.string "linkedin"
    t.string "medium"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "fk_rails_e424190865"
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
    t.integer "num_tokens", default: 0, null: false
    t.index ["dirty"], name: "sweeper"
    t.index ["period", "category", "about", "reputation"], name: "search-2"
    t.index ["period", "category", "about", "track_id", "reputation", "id"], name: "search-5"
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
    t.index ["user_id", "category", "track_id", "value"], name: "index_user_reputation_tokens_profile-sort-covering"
    t.index ["user_id", "category"], name: "index_user_reputation_tokens_on_user_id_and_category"
    t.index ["user_id", "earned_on", "type"], name: "index_user_reputation_tokens_query_3"
    t.index ["user_id", "seen"], name: "index_user_reputation_tokens_on_user_id_and_seen"
    t.index ["user_id", "track_id", "earned_on", "type"], name: "index_user_reputation_tokens_query_4"
    t.index ["user_id", "track_id", "type"], name: "index_user_reputation_tokens_query_2"
    t.index ["user_id", "type"], name: "index_user_reputation_tokens_query_1"
    t.index ["user_id", "value"], name: "index_user_reputation_tokens_on_user_id_and_value"
    t.index ["uuid"], name: "index_user_reputation_tokens_on_uuid", unique: true
  end

  create_table "user_track_acquired_trophies", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "uuid", null: false
    t.bigint "user_id", null: false
    t.bigint "track_id", null: false
    t.bigint "trophy_id", null: false
    t.boolean "revealed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trophy_id"], name: "index_user_track_acquired_trophies_on_trophy_id"
    t.index ["user_id", "trophy_id", "track_id"], name: "index_user_track_acquired_trophies_uniq_guard", unique: true
    t.index ["user_id"], name: "index_user_track_acquired_trophies_on_user_id"
    t.index ["uuid"], name: "index_user_track_acquired_trophies_on_uuid", unique: true
  end

  create_table "user_track_mentorships", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "track_id", null: false
    t.text "bio"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "last_viewed", default: false, null: false
    t.integer "num_finished_discussions", limit: 3, default: 0, null: false
    t.boolean "automator", default: false, null: false
    t.index ["track_id"], name: "fk_rails_4a81f96f88"
    t.index ["user_id", "track_id"], name: "index_user_track_mentorships_on_user_id_and_track_id", unique: true
    t.index ["user_id"], name: "fk_rails_283ecc719a"
  end

  create_table "user_track_viewed_community_solutions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "track_id", null: false
    t.bigint "solution_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "exercise_id", null: false
    t.index ["exercise_id"], name: "index_user_track_viewed_community_solutions_on_exercise_id"
    t.index ["solution_id"], name: "index_user_track_viewed_community_solutions_on_solution_id"
    t.index ["track_id"], name: "index_user_track_viewed_community_solutions_on_track_id"
    t.index ["user_id", "track_id", "solution_id"], name: "index_user_track_viewed_community_solutions_uniq", unique: true
    t.index ["user_id"], name: "index_user_track_viewed_community_solutions_on_user_id"
  end

  create_table "user_track_viewed_exercise_approaches", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "track_id", null: false
    t.bigint "approach_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "exercise_id", null: false
    t.index ["approach_id"], name: "index_user_track_viewed_exercise_approaches_on_approach_id"
    t.index ["exercise_id"], name: "index_user_track_viewed_exercise_approaches_on_exercise_id"
    t.index ["track_id"], name: "index_user_track_viewed_exercise_approaches_on_track_id"
    t.index ["user_id", "track_id", "approach_id"], name: "index_user_track_viewed_exercise_approaches_uniq", unique: true
    t.index ["user_id"], name: "index_user_track_viewed_exercise_approaches_on_user_id"
  end

  create_table "user_tracks", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "track_id", null: false
    t.boolean "anonymous_during_mentoring", default: false, null: false
    t.string "avatar_url"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "summary_key"
    t.text "summary_data"
    t.datetime "last_touched_at", null: false
    t.boolean "practice_mode", default: false, null: false
    t.text "objectives"
    t.integer "reputation", default: 0, null: false
    t.index ["track_id", "user_id"], name: "index_user_tracks_on_track_id_and_user_id", unique: true
    t.index ["user_id"], name: "fk_rails_99e944edbc"
  end

  create_table "user_watched_videos", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "video_provider", null: false
    t.string "video_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "context"
    t.index ["context"], name: "index_user_watched_videos_on_context"
    t.index ["user_id", "video_provider", "video_id"], name: "user_watched_videos_uniq", unique: true
    t.index ["user_id"], name: "index_user_watched_videos_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "handle", limit: 190, null: false
    t.string "avatar_url"
    t.string "email", limit: 190, default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token", limit: 190
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.string "confirmation_token", limit: 190
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "dark_code_theme", default: false, null: false
    t.boolean "default_allow_comments"
    t.datetime "deleted_at", precision: nil
    t.string "location"
    t.string "pronouns"
    t.integer "reputation", default: 0, null: false
    t.datetime "disabled_at"
    t.integer "flair", limit: 1
    t.integer "version", limit: 2, default: 0, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["handle"], name: "index_users_on_handle", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reputation"], name: "index_users_on_reputation"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unconfirmed_email"], name: "index_users_on_unconfirmed_email"
  end

  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "blog_posts", "users", column: "author_id"
  add_foreign_key "cohort_memberships", "cohorts"
  add_foreign_key "cohort_memberships", "users"
  add_foreign_key "cohorts", "tracks"
  add_foreign_key "community_stories", "users", column: "interviewee_id"
  add_foreign_key "community_stories", "users", column: "interviewer_id"
  add_foreign_key "community_videos", "exercises"
  add_foreign_key "community_videos", "tracks"
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
  add_foreign_key "exercise_tags", "exercises"
  add_foreign_key "exercise_taught_concepts", "exercises"
  add_foreign_key "exercise_taught_concepts", "track_concepts"
  add_foreign_key "exercises", "tracks"
  add_foreign_key "github_issue_labels", "github_issues"
  add_foreign_key "github_pull_request_reviews", "github_pull_requests"
  add_foreign_key "github_tasks", "tracks"
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
  add_foreign_key "partner_adverts", "partners"
  add_foreign_key "partner_perks", "partners"
  add_foreign_key "problem_reports", "exercises"
  add_foreign_key "problem_reports", "tracks"
  add_foreign_key "problem_reports", "users"
  add_foreign_key "research_experiment_solutions", "exercises"
  add_foreign_key "research_experiment_solutions", "research_experiments", column: "experiment_id"
  add_foreign_key "research_user_experiments", "research_experiments", column: "experiment_id"
  add_foreign_key "scratchpad_pages", "users"
  add_foreign_key "site_updates", "exercises"
  add_foreign_key "site_updates", "github_pull_requests", column: "pull_request_id"
  add_foreign_key "site_updates", "tracks"
  add_foreign_key "site_updates", "users", column: "author_id"
  add_foreign_key "solution_comments", "solutions"
  add_foreign_key "solution_tags", "exercises"
  add_foreign_key "solution_tags", "solutions"
  add_foreign_key "solution_tags", "users"
  add_foreign_key "solutions", "exercise_approaches"
  add_foreign_key "solutions", "exercise_representations", column: "published_exercise_representation_id"
  add_foreign_key "solutions", "exercises"
  add_foreign_key "solutions", "iterations", column: "published_iteration_id"
  add_foreign_key "solutions", "users"
  add_foreign_key "submission_ai_help_records", "submissions"
  add_foreign_key "submission_analyses", "submissions"
  add_foreign_key "submission_analyses", "tracks"
  add_foreign_key "submission_files", "submissions"
  add_foreign_key "submission_representations", "submissions"
  add_foreign_key "submission_representations", "users", column: "mentor_id"
  add_foreign_key "submission_representations", "users", column: "mentored_by_id"
  add_foreign_key "submission_test_runs", "submissions"
  add_foreign_key "submissions", "exercise_approaches", column: "approach_id"
  add_foreign_key "submissions", "solutions"
  add_foreign_key "team_invitations", "teams"
  add_foreign_key "team_invitations", "users", column: "invited_by_id"
  add_foreign_key "team_memberships", "teams"
  add_foreign_key "team_solutions", "exercises"
  add_foreign_key "team_solutions", "teams"
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
  add_foreign_key "user_mailshots", "mailshots"
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
  add_foreign_key "user_track_viewed_community_solutions", "exercises"
  add_foreign_key "user_track_viewed_community_solutions", "solutions"
  add_foreign_key "user_track_viewed_community_solutions", "tracks"
  add_foreign_key "user_track_viewed_community_solutions", "users"
  add_foreign_key "user_track_viewed_exercise_approaches", "exercise_approaches", column: "approach_id"
  add_foreign_key "user_track_viewed_exercise_approaches", "exercises"
  add_foreign_key "user_track_viewed_exercise_approaches", "tracks"
  add_foreign_key "user_track_viewed_exercise_approaches", "users"
  add_foreign_key "user_tracks", "tracks"
  add_foreign_key "user_tracks", "users"
end
