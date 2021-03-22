module ViewComponents
  module Track
    class ExerciseActivity < ViewComponent
      initialize_with :track, :data

      def to_s
        tag.div(class: "exercise") do
          header + iteration_summary + activities
        end
      end

      def header
        tag.header do
          link_to(Exercism::Routes.track_exercise_url(track, data[:exercise]), class: 'content') do
            exercise_icon(data[:exercise]) +
              tag.div(class: 'info') do
                tag.div(data[:exercise].title, class: 'title') +
                  tag.div(class: 'tags') do
                    status_tag + mentor_tag + unsubmitted_code_tag
                  end
              end
          end + continue_button
        end
      end

      def continue_button
        tag.div(class: 'c-combo-button') do
          link_to("Continue in Editor", editor_url, class: '--editor-segment') +
            tag.div(class: '--dropdown-segment') do
              graphical_icon "chevron-down"
            end
        end
      end

      def status_tag
        case data[:solution][:status]
        when :started
          tag.div("Started", class: 'c-exercise-status-tag --started')
        when :"in-progress"
          tag.div("In progress", class: 'c-exercise-status-tag --in-progress')
        when :completed
          tag.div("Completed", class: 'c-exercise-status-tag --completed')
        when :published
          tag.div("Published", class: 'c-exercise-status-tag --published')
        end
      end

      def mentor_tag
        return unless data[:solution][:num_mentor_comments].positive?

        tag.div(class: "mentor-comments") do
          icon(:mentoring, "Mentor comments #{': Some are unread' if data[:solution][:unread_mentor_comments]}") +
            data[:solution][:num_mentor_comments]
        end
      end

      def unsubmitted_code_tag
        return unless data[:solution][:unsubmitted_code]

        tag.div(class: 'unsubmitted-code') do
          graphical_icon("unsubmitted-code") + "Unsubmitted code" # rubocop:disable Style/StringConcatenation
        end
      end

      def iteration_summary
        return unless data[:latest_iteration]

        link_to(Exercism::Routes.track_exercise_iterations_path(track, data[:exercise], idx: data[:latest_iteration].idx),
          class: 'latest-iteration') do
          ReactComponents::Track::IterationSummary.new(data[:latest_iteration], slim: true).to_s +
            graphical_icon('chevron-right', css_class: "action-icon")
        end
      end

      def activities
        return if data[:activities].blank?

        tag.div(class: "activities") do
          safe_join(
            data[:activities].map do |activity|
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

      def editor_url
        Exercism::Routes.edit_track_exercise_path(track, data[:exercise])
      end
    end
  end
end
