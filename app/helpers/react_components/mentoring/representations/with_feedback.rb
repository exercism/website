module ReactComponents
  module Mentoring
    module Representations
      class WithFeedback < ReactComponent
        initialize_with :mentor, :params

        def to_s
          super(
            "mentoring-representations-with-feedback",
            {
              representations_request:,
              tracks_request:,
              links:,
              sort_options: SORT_OPTIONS
            }
          )
        end

        private
        def representations_request
          {
            endpoint: Exercism::Routes.with_feedback_api_mentoring_representations_url,
            query: {
              criteria: params.fetch(:criteria, ''),
              track_slug: params[:track_slug],
              order: params[:order],
              page: params[:page]
            }.compact,
            options: {
              initial_data: representations,
              stale_time: 5000 # milliseconds
            }
          }
        end

        def representations = AssembleExerciseRepresentationsWithFeedback.(mentor, params)

        def tracks_request
          {
            endpoint: Exercism::Routes.tracks_with_feedback_api_mentoring_representations_url,
            options: {
              initial_data: tracks,
              stale_time: 5000 # milliseconds
            }
          }
        end

        def tracks = AssembleRepresentationTracksForSelect.(mentor, with_feedback: true)

        def links
          { without_feedback: Exercism::Routes.mentoring_automation_index_url }
        end

        SORT_OPTIONS = [
          { value: :num_occurances, label: 'Sort by highest occurance' },
          { value: :recent, label: 'Sort by recent first' }
        ].freeze
        private_constant :SORT_OPTIONS
      end
    end
  end
end
