module ReactComponents
  module Mentoring
    module Representations
      class WithoutFeedback < ReactComponent
        initialize_with :mentor, :params

        def to_s
          super(
            "mentoring-representations-without-feedback",
            {
              representations_request:,
              tracks_request:,
              links:,
              sort_options: SORT_OPTIONS,
              representations_with_feedback_count:,
              is_introducer_hidden:
            }
          )
        end

        private
        def representations_request
          {
            endpoint: Exercism::Routes.without_feedback_api_mentoring_representations_url,
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
            only_mentored_solutions: params[:only_mentored_solutions],
            criteria: params.fetch(:criteria, ''),
            track_slug: params.fetch(:track_slug, track_slugs.first),
            order: params[:order],
            page: params[:page]
          }.compact
        end

        def representations
          AssembleExerciseRepresentationsWithoutFeedback.(mentor, representations_request_params)
        end

        def representations_with_feedback_count
          Exercise::Representation::Search.(mentor:, with_feedback: true, sorted: false, paginated: false,
            track: ::Track.where(slug: track_slugs)).count
        end

        def tracks_request
          {
            endpoint: Exercism::Routes.tracks_without_feedback_api_mentoring_representations_url,
            options: {
              initial_data: tracks,
              stale_time: 5000 # milliseconds
            }
          }
        end

        memoize
        def tracks = AssembleRepresentationTracksForSelect.(mentor, with_feedback: false)

        memoize
        def track_slugs = tracks.map(&:slug)

        def links
          {
            with_feedback: Exercism::Routes.with_feedback_mentoring_automation_index_path,
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
