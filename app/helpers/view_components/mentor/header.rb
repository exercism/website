module ViewComponents
  module Mentor
    class Header < ViewComponent
      TABS = %i[workspace queue testimonials guides].freeze

      initialize_with :selected_tab

      def to_s
        guard!

        tag.nav(class: 'c-mentor-header') do
          tag.div(class: 'lg-container container') do
            lhs + rhs
          end
        end
      end

      private
      def lhs
        tag.nav(class: "lhs") do
          tag.div("Mentoring", class: "title") +
            tag.div(safe_join(tabs), class: 'tabs')
        end
      end

      def rhs; end

      def tabs
        [
          link_to(
            Exercism::Routes.mentoring_inbox_path,
            class: tab_class(:workspace)
          ) do
            graphical_icon(:mentoring) +
              tag.span("Your Workspace") +
              tag.span("20", class: 'count') # TODO
          end,

          link_to(
            Exercism::Routes.mentoring_queue_path,
            class: tab_class(:queue)
          ) do
            graphical_icon(:mentoring) +
              tag.span("Queue") +
              tag.span("1,700", class: 'count')
          end,

          link_to(
            "#",
            class: tab_class(:activity)
          ) do
            graphical_icon(:pulse) +
              tag.span("Activity")
          end,

          link_to(
            Exercism::Routes.mentoring_testimonials_path,
            class: tab_class(:testimonials)
          ) do
            graphical_icon(:testimonials) +
              tag.span("Testimonials")
          end,

          link_to(
            "#",
            class: tab_class(:guides)
          ) do
            graphical_icon(:guides) +
              tag.span("Guides")
          end
        ]
      end

      def tab_class(tab)
        "c-tab-2 #{'selected' if tab == selected_tab}"
      end

      def guard!
        raise "Incorrect track nav tab" unless TABS.include?(selected_tab)
      end
    end
  end
end
