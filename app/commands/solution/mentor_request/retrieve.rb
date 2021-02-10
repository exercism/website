class Solution
  class MentorRequest
    class Retrieve
      include Mandate

      # Use class method rather than constant for
      # easier stubbing during testing
      def self.requests_per_page
        10
      end

      def initialize(user,
                     page: 1,
                     criteria: nil, order: nil,
                     track_slug: nil, exercise_slugs: nil,
                     sorted: true, paginated: true)
        @user = user
        @page = page
        @sorted = sorted
        @paginated = paginated
        @criteria = criteria
        @order = order
        @track_slug = track_slug
        @exercise_slugs = exercise_slugs
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
      attr_reader :user, :page, :criteria, :order,
        :track_slug, :exercise_slugs

      %i[sorted paginated].each do |attr|
        define_method("#{attr}?") { instance_variable_get("@#{attr}") }
      end

      def setup!
        @requests = Solution::MentorRequest.
          joins(:solution).
          includes(solution: [:user, { exercise: :track }]).
          pending.
          unlocked.
          where.not('solutions.user_id': user.id)
      end

      def filter!
        if exercise_slugs.present?
          filter_exercises!
        else
          filter_track!
        end
      end

      def filter_track!
        return if track_slug.blank?

        @requests = @requests.
          joins(solution: :track).
          where('tracks.slug': track_slug)
      end

      def filter_exercises!
        return if track_slug.blank?
        return if exercise_slugs.blank?

        @requests = @requests.
          joins(solution: { exercise: :track }).
          where('tracks.slug': track_slug).
          where('exercises.slug': exercise_slugs)
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
          @requests = @requests.order("solution_mentor_requests.created_at DESC")
        else
          @requests = @requests.order("solution_mentor_requests.created_at")
        end
      end

      def paginate!
        @requests = @requests.
          page(page).per(self.class.requests_per_page)
      end
    end
  end
end
