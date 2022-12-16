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
            query: representations_request_params,
            options: {
              initial_data: representations,
              stale_time: 5000 # milliseconds
            }
          }
        end

        memoize
        def representations_request_params
          {
            criteria: params.fetch(:criteria, ''),
            track_slug: params.fetch(:track_slug, track_slugs.first),
            order: params[:order],
            page: params[:page]
          }.compact
        end

        def representations = AssembleExerciseRepresentationsWithFeedback.(mentor, representations_request_params)

        def representations_without_feedback_count
          Exercise::Representation::Search.(mentor:, with_feedback: false, sorted: false, paginated: false,
            track: ::Track.where(slug: track_slugs)).count
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

        memoize
        def tracks = AssembleRepresentationTracksForSelect.(mentor, with_feedback: true)

        memoize
        def track_slugs = tracks.map { |track| track[:slug] }

        def links
          {
            without_feedback: Exercism::Routes.mentoring_automation_index_path,
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
