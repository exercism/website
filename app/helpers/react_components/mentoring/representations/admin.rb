module ReactComponents
  module Mentoring
    module Representations
      class Admin < ReactComponent
        initialize_with :mentor, :params

        def to_s
          super(
            "mentoring-representations-admin",
            {
              representations_request:,
              tracks: context[:admin][:tracks],
              counts: context.transform_values { |v| v[:representation_count] }.to_h,
              links:,
              sort_options: SORT_OPTIONS,
              is_introducer_hidden:
            }
          )
        end

        private
        def representations_request
          {
            endpoint: Exercism::Routes.admin_api_mentoring_representations_url,
            query: representations_request_params,
            options: {
              initial_data: representations
            }
          }
        end

        memoize
        def representations_request_params
          {
            only_mentored_solutions: params[:only_mentored_solutions],
            criteria: params.fetch(:criteria, ''),
            track_slug: params.fetch(:track_slug, first_track_slug),
            order: params[:order],
            page: params[:page]
          }.compact
        end

        def representations = AssembleExerciseRepresentationsAdmin.(mentor, representations_request_params)

        memoize
        def context = AssembleRepresentationContext.(mentor)

        def first_track_slug = context[:admin][:tracks].map { |track| track[:slug] }.first

        def links
          {
            without_feedback: Exercism::Routes.mentoring_automation_index_path,
            with_feedback: Exercism::Routes.with_feedback_mentoring_automation_index_path,
            hide_introducer: Exercism::Routes.hide_api_settings_introducer_path(INTRODUCER_SLUG)
          }
        end

        def is_introducer_hidden = mentor.introducer_dismissed?(INTRODUCER_SLUG)

        SORT_OPTIONS = [
          { value: :most_recent_feedback, label: 'Most recent feedbacks' },
          { value: :least_recent_feedback, label: 'Least recent feedbacks' }
        ].freeze
        INTRODUCER_SLUG = 'feedback_automation'.freeze
        private_constant :SORT_OPTIONS, :INTRODUCER_SLUG
      end
    end
  end
end
