module Mentor
  class Request
    class Retrieve
      include Mandate

      # Use class method rather than constant for
      # easier stubbing during testing
      def self.requests_per_page
        10
      end

      def initialize(mentor:,
                     page: 1,
                     criteria: nil, order: nil,
                     track_slug: nil, exercise_slug: nil,
                     sorted: true, paginated: true)
        @mentor = mentor
        @page = page
        @criteria = criteria
        @order = order
        @track_slug = track_slug
        @exercise_slug = exercise_slug

        @sorted = sorted
        @paginated = paginated
      end

      def call
        setup!
        filter!
        search!
        sort! if sorted?
        paginate! if paginated?

        @requests
      end

      private
      attr_reader :mentor, :page, :criteria, :order,
        :track_slug, :exercise_slug

      %i[sorted paginated].each do |attr|
        define_method("#{attr}?") { instance_variable_get("@#{attr}") }
      end

      def setup!
        @requests = Mentor::Request.
          joins(:solution).
          includes(solution: [:user, { exercise: :track }]).
          pending.
          unlocked_for(mentor)
      end

      def filter!
        # Don't allow a user to request their own solutions
        @requests = @requests.where.not('solutions.user_id': mentor.id) if mentor

        # Don't show mentor-blocked or student-blocked solutions
        @requests = @requests.where.not(
          'solutions.user_id': Mentor::StudentRelationship.
            where(mentor: mentor).
            where('blocked_by_mentor = ? OR blocked_by_student = ?', true, true).
            select(:student_id)
        )

        if exercise_slug.present?
          filter_exercises!
        else
          filter_track!
        end
      end

      def filter_track!
        if track_slug.present?
          @requests = @requests.
            joins(solution: :track).
            where('tracks.slug': track_slug)
        else
          @requests = @requests.
            joins(solution: :exercise).
            where('exercise.track_id': mentor.mentored_tracks)
        end
      end

      def filter_exercises!
        return if track_slug.blank?
        return if exercise_slug.blank?

        @requests = @requests.
          joins(solution: { exercise: :track }).
          where('tracks.slug': track_slug).
          where('exercises.slug': exercise_slug)
      end

      def search!
        return if criteria.blank?

        # TODO: This is just a stub implementation
        @requests = @requests.joins(:user).where("users.handle LIKE ?", "%#{criteria}%")
      end

      def sort!
        # TODO: This is just a stub implementation
        case order
        when "exercise"
          @requests = @requests.joins(solution: :exercise).order("exercises.name ASC")
        when "student"
          @requests = @requests.joins(:user).order("users.name ASC")
        when "recent"
          @requests = @requests.order("mentor_requests.created_at DESC")
        else
          @requests = @requests.order("mentor_requests.created_at")
        end
      end

      def paginate!
        @requests = @requests.
          page(page).per(self.class.requests_per_page)
      end
    end
  end
end
