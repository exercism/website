module ReactComponents
  module Mentoring
    class Inbox < ReactComponent
      def initialize(conversations_request = default_conversations_request, tracks_request = default_tracks_request)
        @conversations_request = conversations_request
        @tracks_request = tracks_request
      end

      def to_s
        super(
          "mentoring-inbox",
          {
            conversations_request: conversations_request,
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

      private
      attr_reader :conversations_request, :tracks_request

      def default_conversations_request
        { endpoint: Exercism::Routes.api_mentor_inbox_path }
      end

      def default_tracks_request
        # TODO: Change this to the actual endpoint, not the test endpoint
        { endpoint: Exercism::Routes.tracks_test_components_mentoring_inbox_path }
        # { endpoint: Exercism::Routes.api_mentor_inbox_path }
      end
    end
  end
end
