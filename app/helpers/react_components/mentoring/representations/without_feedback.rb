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
              tracks: context[:without_feedback][:tracks],
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
            endpoint: Exercism::Routes.without_feedback_api_mentoring_representations_url,
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

        def representations
          AssembleExerciseRepresentationsWithoutFeedback.(mentor, representations_request_params)
        end

        memoize
        def context = AssembleRepresentationContext.(mentor)

        def first_track_slug = context[:without_feedback][:tracks].map { |track| track[:slug] }.first

        def links
          {
            with_feedback: Exercism::Routes.with_feedback_mentoring_automation_index_path,
            admin: Exercism::Routes.admin_mentoring_automation_index_path,
            hide_introducer: Exercism::Routes.hide_api_settings_introducer_path(INTRODUCER_SLUG)
          }
        end

        def is_introducer_hidden = mentor.introducer_dismissed?(INTRODUCER_SLUG)

        SORT_OPTIONS = [
          { value: :most_submissions, label: 'Sort by highest occurence' },
          { value: :most_recent, label: 'Sort by recent first' }
        ].freeze
        INTRODUCER_SLUG = 'feedback_automation'.freeze
        private_constant :SORT_OPTIONS, :INTRODUCER_SLUG
      end
    end
  end
end
