module ReactComponents
  module Mentoring
    class Inbox < ReactComponent
      initialize_with :params

      def to_s
        super(
          "mentoring-inbox",
          {
            discussions_request:,
            tracks_request:,
            sort_options:,
            links: {
              queue: Exercism::Routes.mentoring_queue_path
            }
          }
        )
      end

      DEFAULT_STATUS = "awaiting_mentor".freeze
      private_constant :DEFAULT_STATUS

      private
      def sort_options
        [
          { value: :recent, label: I18n.t("components.mentoring.inbox.sort_options.recent_first") },
          { value: :oldest, label: I18n.t("components.mentoring.inbox.sort_options.oldest_first") },
          { value: :exercise, label: I18n.t("components.mentoring.inbox.sort_options.exercise") },
          { value: :student, label: I18n.t("components.mentoring.inbox.sort_options.student") }
        ]
      end

      def discussions_request
        {
          endpoint: Exercism::Routes.api_mentoring_discussions_path(sideload: [:all_discussion_counts]),
          query: {
            status: params[:status] || DEFAULT_STATUS,
            order: params[:order],
            criteria: params[:criteria],
            page: params[:page] ? params[:page].to_i : 1,
            track_slug: params[:track_slug]
          }.compact,
          options: { stale_time: 0 }
        }
      end

      def tracks_request
        {
          endpoint: Exercism::Routes.tracks_api_mentoring_discussions_path,
          query: { status: params[:status] || DEFAULT_STATUS },
          options: { stale_time: 0 }
        }
      end
    end
  end
end
