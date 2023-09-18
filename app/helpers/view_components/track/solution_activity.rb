module ViewComponents
  module Track
    class SolutionActivity < ViewComponent
      initialize_with :solution, :user_track

      def to_s
        tag.div(class: "exercise") do
          header + iteration_summary + activities
        end
      end

      def header
        tag.header do
          link_to(Exercism::Routes.track_exercise_url(track, exercise), class: 'content') do
            render(
              ReactComponents::Common::ExerciseWidget.new(
                exercise, user_track, solution:,
                render_as_link: false, render_blurb: false, render_track: false
              )
            )
          end + continue_button
        end
      end

      def continue_button
        render ::ReactComponents::Student::OpenEditorButton.new(exercise, user_track)
      end

      def status_tag
        render ViewComponents::Track::ExerciseStatusTag.new(exercise, user_track)
      end

      def mentor_tag
        return unless num_mentor_comments.positive?

        tag.div(class: "mentor-comments") do
          icon(:mentoring, "Mentor comments #{': Some are unread' if has_unread_mentor_comments?}") +
            num_mentor_comments
        end
      end

      def unsubmitted_code_tag
        return unless solution.has_unsubmitted_code?

        tag.div(class: 'unsubmitted-code') do
          graphical_icon("unsubmitted-code") + "Unsubmitted code" # rubocop:disable Style/StringConcatenation
        end
      end

      def iteration_summary
        return unless solution.latest_iteration

        link_to(Exercism::Routes.track_exercise_iterations_path(track, exercise, idx: solution.latest_iteration.idx),
          class: 'latest-iteration') do
          ReactComponents::Track::IterationSummary.new(solution.latest_iteration, slim: true).to_s +
            graphical_icon('chevron-right', css_class: "action-icon filter-textColor6")
        end
      end

      def activities
        return unless solution.latest_iteration
        return if activities_data.blank?

        tag.div(class: "activities") do
          safe_join(
            activities_data.map do |activity|
              tag.div(class: 'activity') do
                tag.div(graphical_icon(activity[:icon_name]), class: 'icon') +
                tag.div(raw(activity[:text]), class: 'description') +
                tag.time("#{time_ago_in_words(activity[:occurred_at], short: true)} ago") +
                graphical_icon('chevron-right', css_class: "action-icon")
              end
            end
          )
        end
      end

      memoize
      def editor_url
        Exercism::Routes.edit_track_exercise_path(track, exercise)
      end

      memoize
      delegate :exercise, to: :solution

      def num_mentor_comments
        mentor_comments[:count]
      end

      def has_unread_mentor_comments?
        mentor_comments[:unread]
      end

      memoize
      def mentor_comments
        discussion = solution.mentor_discussions.last
        return { count: 0, unread: false } unless discussion

        counts = discussion.posts.group(:seen_by_student).count

        {
          count: counts.values.sum,
          unread: !!counts[false]&.positive?
        }
      end

      memoize
      def activities_data
        solution.user_activities.order(id: :desc).limit(5).map(&:rendering_data)
      rescue StandardError
        []
      end

      memoize
      delegate :track, to: :user_track
    end
  end
end
