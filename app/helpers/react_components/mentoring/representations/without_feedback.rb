module ReactComponents
  module Mentoring
    module Representations
      class WithoutFeedback < ReactComponent
        initialize_with :params

        def to_s
          super(
            "mentoring-representations-without-feedback",
            {
              discussions_request:,
              tracks_request:,
              sort_options: SORT_OPTIONS
            }
          )
        end

        SORT_OPTIONS = [
          { value: :num_occurances, label: 'Sort by highest occurance' },
          { value: :recent, label: 'Sort by recent first' }
        ].freeze
        private_constant :SORT_OPTIONS

        DEFAULT_STATUS = "awaiting_mentor".freeze
        private_constant :DEFAULT_STATUS

        private
        def discussions_request
          {
            # endpoint: Exercism::Routes.api_mentoring_discussions_path(sideload: [:all_discussion_counts]),
            # query: {
            #   status: params[:status] || DEFAULT_STATUS,
            #   order: params[:order],
            #   criteria: params[:criteria],
            #   page: params[:page] ? params[:page].to_i : 1,
            #   track_slug: params[:track_slug]
            # }.compact,
            # options: { stale_time: 0 }
          }
        end

        def tracks_request
          {
            # endpoint: Exercism::Routes.tracks_api_mentoring_discussions_path,
            # query: { status: params[:status] || DEFAULT_STATUS },
            # options: { stale_time: 0 }
          }
        end
      end
    end
  end
end
