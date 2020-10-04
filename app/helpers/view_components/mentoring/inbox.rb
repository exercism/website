module ViewComponents
  module Mentoring
    class Inbox < ViewComponent
      attr_reader :conversations_request, :tracks_request

      def initialize(conversations_request = default_conversations_request, tracks_request = default_tracks_request)
        @conversations_request = conversations_request
        @tracks_request = tracks_request
      end

      def to_s
        react_component(
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
      def default_conversations_request
        # TODO: Change this to the actual endpoint, not the test endpoint
        { endpoint: Exercism::Routes.conversations_test_components_mentoring_inbox_path }
      end

      def default_tracks_request
        # TODO: Change this to the actual endpoint, not the test endpoint
        { endpoint: Exercism::Routes.tracks_test_components_mentoring_inbox_path }
      end
    end
  end
end
