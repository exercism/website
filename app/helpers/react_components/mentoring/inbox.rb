module ReactComponents
  module Mentoring
    class Inbox < ReactComponent
      def initialize(discussions_request = default_discussions_request, tracks_request = default_tracks_request)
        @discussions_request = discussions_request
        @tracks_request = tracks_request
      end

      def to_s
        super(
          "mentoring-inbox",
          {
            # TODO: Rename to discussions
            conversations_request: discussions_request,
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
      attr_reader :discussions_request, :tracks_request

      def default_discussions_request
        { endpoint: Exercism::Routes.api_mentor_discussions_path }
      end

      def default_tracks_request
        { endpoint: Exercism::Routes.tracks_api_mentor_discussions_path }
      end
    end
  end
end
