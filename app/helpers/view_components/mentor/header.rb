module ViewComponents
  module Mentor
    class Header < ViewComponent
      TABS = %i[workspace queue testimonials guides].freeze

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
          # TODO
          tag.div("131 solutions mentored", class: "stat") +
            # TODO
            tag.div("95% satisfaction", class: "stat")
        end
      end

      def tabs
        [
          link_to(
            Exercism::Routes.mentoring_inbox_path,
            class: tab_class(:workspace)
          ) do
            graphical_icon(:overview) +
              tag.span("Your Workspace") +
              tag.span("20", class: 'count') # TODO
          end,

          link_to(
            Exercism::Routes.mentoring_queue_path,
            class: tab_class(:queue)
          ) do
            graphical_icon(:queue) +
              tag.span("Queue") +
              tag.span("1,700", class: 'count') # TODO
          end,

          link_to(
            Exercism::Routes.mentoring_testimonials_path,
            class: tab_class(:testimonials)
          ) do
            graphical_icon(:testimonials) +
              tag.span("Testimonials")
          end,

          tag.div(
            class: "#{tab_class(:automation)} locked",
            'aria-label': "This tab is locked"
          ) do
            graphical_icon(:automation) +
              tag.span("Automation")
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
