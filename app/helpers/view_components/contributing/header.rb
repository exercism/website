module ViewComponents
  module Contributing
    class Header < ViewComponent
      TABS = %i[dashboard contributors].freeze

      initialize_with :selected_tab

      def to_s
        guard!

        tag.nav(class: 'c-contributing-header c-header-with-bg') do
          top + nav
        end
      end

      def top
        tag.div(class: 'lg-container top-container') do
          tag.div(class: 'content') do
            graphical_icon("contributing-header") +
              tag.h1("Let’s build the best free code learning platform, together") +
              tag.p do
                safe_join(
                  [
                    "Exercism is an ",
                    link_to("open source, not-for-profit project", "#"),
                    " built by people from all backgrounds.  With over one hundred dedicated maintainers and thousands of contributors, our goal is to create the best, free, code learning platform on the web." # rubocop:disable Layout/LineLength
                  ]
                )
              end
          end +
            graphical_icon("contributing-header", category: "graphics") +
            tag.div('', class: 'decorations')
        end
      end

      def nav
        tag.div(class: 'lg-container nav-container') do
          tag.div(safe_join(tabs), class: 'tabs') +
            link_to(Exercism::Routes.docs_section_path(:mentoring), class: "c-tab-2 guides") do
              graphical_icon(:guides) + tag.span("Contributing Help")
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
            Exercism::Routes.contributing_root_path,
            class: tab_class(:dashboard)
          ) do
            graphical_icon(:overview) +
              tag.span("Getting Started")
          end,

          link_to(
            "#",
            class: tab_class(:tasks)
          ) do
            graphical_icon(:tasks) +
              tag.span("Explore tasks") +
              tag.span(number_with_delimiter(tasks_size), class: 'count')
          end,

          link_to(
            Exercism::Routes.contributing_contributors_path,
            class: tab_class(:contributors)
          ) do
            graphical_icon(:contributors) +
              tag.span("Contributors")
          end

        ]
      end

      def tab_class(tab)
        "c-tab-2 #{'selected' if tab == selected_tab}"
      end

      def guard!
        raise "Incorrect track nav tab" unless TABS.include?(selected_tab)
      end

      memoize
      def tasks_size
        ::Mentor::Discussion.joins(solution: :exercise).
          where(mentor: current_user).
          awaiting_mentor.
          count
      end
    end
  end
end
