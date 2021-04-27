module ReactComponents
  module Mentoring
    class Inbox < ReactComponent
      def to_s
        super(
          "mentoring-inbox",
          {
            discussions_request: discussions_request,
            tracks_request: tracks_request,
            sort_options: SORT_OPTIONS
          }
        )
      end

      SORT_OPTIONS = [
        { value: 'recent', label: 'Sort by Most Recent' },
        { value: 'exercise', label: 'Sort by Exercise' },
        { value: 'student', label: 'Sort by Student' }
      ].freeze
      private_constant :SORT_OPTIONS

      DEFAULT_STATUS = "awaiting_mentor".freeze
      private_constant :DEFAULT_STATUS

      private
      def discussions_request
        {
          endpoint: Exercism::Routes.api_mentoring_discussions_path(sideload: [:all_discussion_counts]),
          query: { status: DEFAULT_STATUS }
        }
      end

      def tracks_request
        {
          endpoint: Exercism::Routes.tracks_api_mentoring_discussions_path,
          query: { status: DEFAULT_STATUS }
        }
      end
    end
  end
end
