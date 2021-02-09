class Solution
  class MentorDiscussion
    class Retrieve
      include Mandate

      REQUESTS_PER_PAGE = 10

      def self.requests_per_page
        REQUESTS_PER_PAGE
      end

      def initialize(user,
                     page: nil,
                     criteria: nil, order: nil,
                     track_slug: nil,
                     sorted: true, paginated: true)
        @user = user
        @page = page || 1
        @track_slug = track_slug
        @criteria = criteria
        @order = order

        @sorted = sorted
        @paginated = paginated
      end

      def call
        setup!
        filter_track! if track_slug.present?
        search! if criteria
        sort! if sorted?
        paginate! if paginated?

        @discussions
      end

      private
      attr_reader :user, :page, :track_slug, :criteria, :order

      %i[sorted paginated].each do |attr|
        define_method("#{attr}?") { instance_variable_get("@#{attr}") }
      end

      def setup!
        @discussions = Solution::MentorDiscussion.
          joins(solution: :exercise).
          includes(solution: [:user, { exercise: :track }]).
          where(mentor: user).
          requires_mentor_action
      end

      # TODO: This is just a stub implementation
      def filter_track!
        @discussions = @discussions.where(tracks: { slug: track_slug })
      end

      # TODO: This is just a stub implementation
      def search!
        @discussions = @discussions.where("exercises.title LIKE ?", "%#{criteria}%")
      end

      # TODO: This is just a stub implementation
      def sort!
        case order
        when "exercise"
          @discussions = @discussions.order("exercises.title")
        else
          @discussions = @discussions.order(requires_mentor_action_since: :asc)
        end
      end

      def paginate!
        @discussions = @discussions.page(page).per(self.class.requests_per_page)
      end
    end
  end
end
