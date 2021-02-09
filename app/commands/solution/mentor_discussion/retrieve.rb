class Solution
  class MentorDiscussion
    class Retrieve
      include Mandate

      REQUESTS_PER_PAGE = 10

      def self.requests_per_page
        REQUESTS_PER_PAGE
      end

      def initialize(user, page: nil, track_slug: nil, criteria: nil, order: nil)
        @user = user
        @page = page || 1
        @track_slug = track_slug
        @criteria = criteria
        @order = order
      end

      def call
        retrieve!
        filter_track! if track_slug
        search! if criteria
        sort!
        paginate!

        @discussions
      end

      private
      attr_reader :user, :page, :track_slug, :criteria, :order

      def retrieve!
        @discussions = Solution::MentorDiscussion.
          joins(solution: :exercise).
          includes(solution: [:user, { exercise: :track }]).
          where(mentor: user).
          requires_mentor_action

        @discussions.tap do |res|
          filtered_tracks = Track.where(id: @discussions.select('exercises.track_id'))
          res.class.define_method(:tracks) { filtered_tracks }
        end
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
          @discussions = @discussions.order(requires_mentor_action_since: :desc)
        end
      end

      def paginate!
        @discussions = @discussions.page(page).per(self.class.requests_per_page)
      end
    end
  end
end
