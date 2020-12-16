module ViewComponents
  module Mentor
    class Nav < ViewComponent
      TABS = %i[dashboard testimonials guides].freeze

      initialize_with :selected_tab

      def to_s
        guard!

        tag.nav(class: 'c-mentor-nav') do
          tag.div(class: 'md-container container') do
            safe_join([
                        tag.div(safe_join(tabs), class: 'tabs')
                      ])
          end
        end
      end

      def tabs
        [
          link_to(
            Exercism::Routes.mentor_dashboard_path,
            class: tab_class(:dashboard)
          ) do
            graphical_icon(:dashboard) +
              tag.span("Mentoring Area", "data-text": "Mentoring Area")
          end,

          link_to(
            "#",
            class: tab_class(:testimonials)
          ) do
            graphical_icon(:testimonials) +
              tag.span("Testimonials", "data-text": "Testimonials")
          end,

          link_to(
            "#",
            class: tab_class(:guides)
          ) do
            graphical_icon(:guides) +
              tag.span("Guides", "data-text": "Guides")
          end
        ]
      end

      def tab_class(tab)
        "c-tab #{'selected' if tab == selected_tab}"
      end

      def guard!
        raise "Incorrect track nav tab" unless TABS.include?(selected_tab)
      end
    end
  end
end
