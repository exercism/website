module ReactComponents
  module Mentoring
    class Inbox < ReactComponent
      initialize_with :params

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
          query: {
            status: params[:status] || DEFAULT_STATUS,
            order: params[:order],
            criteria: params[:criteria],
            page: params[:page],
            track: params[:track]
          }.compact
        }
      end

      def tracks_request
        {
          endpoint: Exercism::Routes.tracks_api_mentoring_discussions_path,
          query: { status: params[:status] || DEFAULT_STATUS }
        }
      end
    end
  end
end
