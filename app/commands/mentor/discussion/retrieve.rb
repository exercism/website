module Mentor
  class Discussion
    class Retrieve
      include Mandate

      REQUESTS_PER_PAGE = 10

      def self.requests_per_page
        REQUESTS_PER_PAGE
      end

      def initialize(user,
                     status,
                     page: nil,
                     criteria: nil, order: nil,
                     track_slug: nil,
                     sorted: true, paginated: true)

        # TODO: Guard valid status

        @user = user
        @status = status.to_sym
        @page = page || 1
        @track_slug = track_slug
        @criteria = criteria
        @order = order

        @sorted = sorted
        @paginated = paginated
      end

      def call
        setup!
        filter_status!
        filter_track! if track_slug.present?
        search! if criteria.present?
        sort! if sorted?
        paginate! if paginated?

        @discussions
      end

      private
      attr_reader :user, :status, :page, :track_slug, :criteria, :order

      %i[sorted paginated].each do |attr|
        define_method("#{attr}?") { instance_variable_get("@#{attr}") }
      end

      def setup!
        @discussions = Mentor::Discussion.
          joins(solution: :exercise).
          includes(solution: [:user, { exercise: :track }]).
          where(mentor: user)
      end

      def filter_status!
        case status
        when :requires_mentor_action
          @discussions = @discussions.requires_mentor_action
        when :requires_student_action
          @discussions = @discussions.requires_student_action
        when :finished
          @discussions = @discussions.finished
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
          @discussions = @discussions.order(requires_mentor_action_since: :asc)
        end
      end

      def paginate!
        @discussions = @discussions.page(page).per(self.class.requests_per_page)
      end
    end
  end
end
