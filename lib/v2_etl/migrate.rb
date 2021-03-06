# Run in a rails console with:
# require 'v2_etl/migrate'; V2ETL::Migrate.()

module V2ETL
  class Migrate
    include Mandate

    def call
      return if Rails.env.production?

      # `mysql -u root -e "drop database small_website_etl"`
      # `mysql -u root -e "create database small_website_etl"`
      # `mysql -u root small_website_etl < small-dump-for-v3-etl.sql`

      # Disable foreign key checks for speed
      ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS=0")

      # The calls to reload in this method fix issues
      # with ActiveRecord caching the state of db tables.
      pre_create_tables!
      reload!

      create_tables!
      reload!

      migrate_tables!
      reload!

      migrate_data!
      reload!

      # Bring the schema migrations table up to daet
      update_schema_migrations!

      # Reenable foreign key checks for integrity
      ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS=1")

      # Final reload for anything that might come after, such as tests
      reload!

      # TODO: Remove this.
      u = User.find_by(id: 1530)
      if u
        u.update(email: 'ihid@exercism.io')
        u.confirm
        u.update(password: "password")
      end
    end

    def pre_create_tables!
      # Move submissions sideways. These tables are too
      # different to migrate so need data moving between them
      # rather than just having columns changed.
      rename_table :discussion_posts, :v2_discussion_posts

      # TODO: Work out what to do with these three.
      rename_table :submissions, :v2_submissions
      rename_table :submission_test_runs, :v2_submission_test_runs
      rename_table :notifications, :v2_notifications

      # Remove duplicate foreign key on sideways table
      begin
        execute("ALTER TABLE v2_submission_test_runs DROP FOREIGN KEY fk_rails_477e62a0ba")
      rescue ActiveRecord::StatementInvalid
        # It seems that the import/export of the db means that sometimes
        # this doesn't appear.
      end

      # Rename tables
      rename_table :solution_mentorships, :mentor_discussions
      rename_table :iteration_files, :submission_files
      rename_table :profiles, :user_profiles
      rename_table :track_mentorships, :user_track_mentorships
    end

    def create_tables!
      # Create any new tables first
      # This ensures foreign keys will be present
      create_track_concepts
      create_user_track_learnt_concepts
      create_exercise_prerequisites
      create_exercise_taught_concepts
      create_exercise_practiced_concepts
      create_submissions
      create_submission_test_runs
      create_submission_analyses

      create_exercise_representations
      create_submission_representations

      create_mentor_requests
      create_mentor_request_locks
      create_mentor_discussion_posts
      create_mentor_testimonials
      create_mentor_student_relationships

      create_badges
      create_problem_reports
      create_exercise_authorships
      create_exercise_contributorships
      create_scratchpad_pages
      create_user_acquired_badges
      create_user_notifications
      create_user_activities
      create_user_auth_tokens
      create_user_reputation_tokens

      create_github_pull_requests
      create_github_organization_members

      create_documents
    end

    # Make any structural changes to the tables
    def migrate_tables!
      migrate_friendly_id_slugs
      migrate_mentor_discussions
      migrate_exercises
      migrate_iterations
      migrate_submission_files
      migrate_tracks
      migrate_user_profiles
      migrate_user_track_mentorships
      migrate_user_tracks
      migrate_solutions
      migrate_users
    end

    def migrate_data!
      # Now do lots of data migrations
      # Each of these should have a class associated with
      # it and an equivlent test class
      process_mentor_discussion_posts
      process_mentor_requests
      process_mentor_student_relationships
      process_anonymous_mode

      # This needs to come after the mentor migrations as
      # it uses their values to determine status
      process_solutions
      process_activities

      process_mentoring_reputation
      process_publishing_reputation
      process_users

      # This is worth doing last as it's the least likely to fail
      # and the least damanging if it does.
      process_tracks
      # process_user_tracks

      # TODO: Populate users.github_usernames via GH API

      # TODO: Migrate users.is_mentor to users.became_mentor_at
      # based on the first solution_mentorship

    end

    def method_missing(meth) # rubocop:disable Style/MissingRespondToMissing
      if meth.starts_with?("create_")
        handle_create(meth)
      elsif meth.starts_with?("migrate_")
        handle_migrate(meth)
      elsif meth.starts_with?("process_")
        handle_process(meth)
      else
        super(meth)
      end
    end

    def handle_create(meth)
      Rails.logger.info "Running #{meth}"
      file = Dir[Rails.root.join("db/migrate/*_#{meth}.rb")].first
      require file

      meth.to_s.camelize.constantize.new.change
    end

    def handle_migrate(meth)
      Rails.logger.info "Running #{meth}"
      file = Dir[Rails.root.join("lib/v2_etl/table_migrations/#{meth}.rb")].first
      require file

      "v2_e_t_l/table_migrations/#{meth}".camelize.constantize.()
    end

    def handle_process(meth)
      Rails.logger.info "Running #{meth}"
      file = Dir[Rails.root.join("lib/v2_etl/data_processors/#{meth}.rb")].first
      require file

      "v2_e_t_l/data_processors/#{meth}".camelize.constantize.()
    end

    def migrate_friendly_id_slugs
      # Noop
    end

    def update_schema_migrations!
      Dir[Rails.root.join("db", "migrate", "*.rb")].each do |migration|
        id = migration.split("/").last.split("_").first
        connection.execute("INSERT INTO schema_migrations VALUES ('#{id}')")
      rescue
        # Rescue in case a matching migration id already exists
      end
    end

    private
    delegate :rename_table, :execute, to: :connection

    def reload!
      # Reload everything
      ActiveRecord::Base.descendants.each(&:reset_column_information)
    end

    def connection
      ActiveRecord::Base.connection
    end
  end
end
