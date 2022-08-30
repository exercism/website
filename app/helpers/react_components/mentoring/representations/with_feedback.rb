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
              sort_options: SORT_OPTIONS,
              representations_without_feedback_count:,
              is_introducer_hidden:
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

        def representations_without_feedback_count
          Exercise::Representation::Search.(mentor:, with_feedback: false, sorted: false, paginated: false).count
        end

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
          {
            without_feedback: Exercism::Routes.mentoring_automation_index_url,
            hide_introducer: Exercism::Routes.hide_api_settings_introducer_path(INTRODUCER_SLUG)
          }
        end

        def is_introducer_hidden = mentor.introducer_dismissed?(INTRODUCER_SLUG)

        SORT_OPTIONS = [
          { value: :most_submissions, label: 'Sort by highest occurance' },
          { value: :most_recent, label: 'Sort by recent first' }
        ].freeze
        INTRODUCER_SLUG = 'feedback_automation'.freeze
        private_constant :SORT_OPTIONS, :INTRODUCER_SLUG
      end
    end
  end
end
