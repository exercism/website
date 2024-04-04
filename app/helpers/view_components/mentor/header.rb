module ViewComponents
  module Mentor
    class Header < ViewComponent
      TABS = %i[workspace queue testimonials guides automation].freeze

      initialize_with :selected_tab

      def to_s
        guard!

        tag.nav(class: 'c-mentor-header') do
          tag.div(class: 'lg-container container') do
            top + bottom
          end
        end
      end

      def top
        tag.nav(class: "top") do
          tag.div(class: "title") do
            graphical_icon(:mentoring, hex: true) +
              tag.span("Mentoring")
          end + stats
        end
      end

      def bottom
        tag.nav(class: "bottom") do
          tag.div(safe_join(tabs), class: 'tabs') +
            link_to(Exercism::Routes.docs_section_path(:mentoring), class: "c-tab-2 guides") do
              graphical_icon(:guides) + tag.span("Mentoring Guides")
            end
        end
      end

      def stats
        tag.div(class: "stats") do
          safe_join(
            [
              tag.div("#{current_user.num_solutions_mentored} discussions completed", class: "stat"),
              (if current_user.mentor_satisfaction_percentage
                 tag.div("#{current_user.mentor_satisfaction_percentage}% satisfaction",
                   class: "stat")
               end)
            ].compact
          )
        end
      end

      def tabs = [workspace_tab, queue_tab, testimonials_tab, automation_tab]

      def workspace_tab
        link_to(
          Exercism::Routes.mentoring_inbox_path,
          class: tab_class(:workspace)
        ) do
          graphical_icon(:overview) +
            tag.span("Your Workspace") +
            tag.span(number_with_delimiter(inbox_size), class: 'count')
        end
      end

      def queue_tab
        link_to(
          Exercism::Routes.mentoring_queue_path,
          class: tab_class(:queue)
        ) do
          graphical_icon(:queue) +
            tag.span("Queue") +
            tag.span(number_with_delimiter(queue_size), class: 'count')
        end
      end

      def testimonials_tab
        link_to(
          Exercism::Routes.mentoring_testimonials_path,
          class: tab_class(:testimonials)
        ) do
          graphical_icon(:testimonials) +
            tag.span("Testimonials") +
            tag.span(number_with_delimiter(num_testimonials), class: 'count')
        end
      end

      def automation_tab
        unless current_user.automator?
          return tag.div(
            class: "#{tab_class(:automation)} locked",
            'aria-label': 'This tab is locked',
            'data-tooltip-type': 'automation-locked',
            'data-endpoint': Exercism::Routes.tooltip_locked_mentoring_automation_index_path,
            'data-placement': 'bottom',
            'data-interactive': true
          ) do
            graphical_icon(:automation) +
            tag.span("Automation")
          end
        end

        link_to(
          Exercism::Routes.mentoring_automation_index_path,
          class: tab_class(:automation)
        ) do
          graphical_icon(:automation) +
            tag.span("Automation") # +
          # tag.span(number_with_delimiter(num_representations_without_feedback), class: 'count')
        end
      end

      def tab_class(tab)
        "c-tab-2 #{'selected' if tab == selected_tab}"
      end

      def guard!
        raise "Incorrect track nav tab" unless TABS.include?(selected_tab)
      end

      memoize
      def inbox_size
        ::Mentor::Discussion.joins(solution: :exercise).
          where(mentor: current_user).
          awaiting_mentor.
          count
      end

      memoize
      def queue_size
        ::Mentor::Request::Retrieve.(
          mentor: current_user,
          sorted: false,
          paginated: false
        ).count
      end

      memoize
      def num_testimonials
        current_user.mentor_testimonials.count
      end

      memoize
      def num_representations_without_feedback
        ::Exercise::Representation.without_feedback.
          joins(exercise: :track).
          where(exercises: { track: current_user.mentored_tracks }).
          count
      end
    end
  end
end
