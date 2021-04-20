module Mentor
  class Discussion
    class Retrieve
      include Mandate

      REQUESTS_PER_PAGE = 10

      def self.requests_per_page
        REQUESTS_PER_PAGE
      end

      def initialize(mentor,
                     status,
                     page: nil,
                     criteria: nil, order: nil,
                     track_slug: nil,
                     sorted: true, paginated: true)

        # TODO: Guard valid status

        @mentor = mentor
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
      attr_reader :mentor, :status, :page, :track_slug, :criteria, :order

      %i[sorted paginated].each do |attr|
        define_method("#{attr}?") { instance_variable_get("@#{attr}") }
      end

      def setup!
        @discussions = Mentor::Discussion.
          joins(solution: :exercise).
          includes(solution: [:user, { exercise: :track }]).
          where(mentor: mentor)
      end

      def filter_status!
        case status
        when :awaiting_mentor
          @discussions = @discussions.awaiting_mentor
        when :awaiting_student
          @discussions = @discussions.awaiting_student
        when :finished
          @discussions = @discussions.finished_for_mentor
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
          @discussions = @discussions.order(awaiting_mentor_since: :asc)
        end
      end

      def paginate!
        @discussions = @discussions.page(page).per(self.class.requests_per_page)
      end
    end
  end
end
