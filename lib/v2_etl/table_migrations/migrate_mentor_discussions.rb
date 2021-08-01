require_relative "table_migration"

module V2ETL
  module TableMigrations
    class MigrateMentorDiscussions < TableMigration
      include Mandate

      def table_name
        "mentor_discussions"
      end

      def model
        Mentor::Discussion
      end

      def call
        # Add UUID
        add_non_nullable_column :uuid, :string, "UUID()"
        add_index :uuid, unique: true

        # Other adds
        add_column :requires_student_action_since, :datetime
        add_column :num_posts, :integer, limit: 3, null: false, default: 0
        add_column :anonymous_mode, :boolean, null: false, default: false

        # Remove unused
        remove_column :show_feedback_to_mentor

        # Renames
        rename_column :user_id, :mentor_id
        rename_column :requires_action_since, :awaiting_mentor_since
        remove_column :requires_action
        add_column :awaiting_student_since, :datetime

        discussions_with_feedback = Mentor::Discussion.where.not(feedback: nil).
          where.not(feedback: "").
          includes(:solution)
        discussions_with_feedback.find_each do |discussion|
          Mentor::Testimonial.create!(
            mentor_id: discussion.mentor_id,
            discussion: discussion,
            student_id: discussion.solution.user_id,
            content: discussion.feedback,
            revealed: true,
            created_at: discussion.updated_at,
            updated_at: discussion.updated_at
          )
        end
        remove_column :feedback

        # TOOD: Decide about mentor_reminder_sent_at

        # Create request_id
        add_column :request_id, :bigint, null: true
        add_foreign_key :mentor_requests, column: :request_id

        migrate_statuses!

        # TODO: Populate num_posts
      end

      def migrate_statuses!
        # Add columns
        add_column :status, :tinyint, null: false, default: 0
        add_column :finished_at, :datetime
        add_column :finished_by, :tinyint

        # Mark Approved as completed
        completed_solutions = Solution.where.not(completed_at: nil)
        Mentor::Discussion.where(status: 0).where(solution: completed_solutions).update_all(status: :finished)

        # Mark Approved as completed
        approved_solutions = Solution.where.not(approved_by_id: nil)
        Mentor::Discussion.where(status: 0).where(solution: approved_solutions).update_all(status: :mentor_finished)

        # Mark abandoned as completed
        model.where(status: 0).where(abandoned: true).update_all(status: :finished)

        # Mark as awaiting mentor
        model.where(status: 0).where.not(awaiting_mentor_since: nil).update_all(status: :awaiting_mentor)

        # TODO: Use variable for times
        Mentor::Discussion.where(status: :finished).update_all(
          finished_at: Time.current
        )

        # Remove unnneeded columns
        remove_column :abandoned
      end
    end
  end
end
