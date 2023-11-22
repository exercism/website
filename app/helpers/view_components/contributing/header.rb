module ViewComponents
  module Contributing
    class Header < ViewComponent
      TABS = %i[dashboard contributors tasks].freeze

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
              tag.h1("Let’s build the best coding education platform, together") +
              tag.p do
                safe_join(
                  [
                    "Exercism is an ",
                    link_to("open source, not-for-profit project", Exercism::Routes.about_path),
                    " built by people from all backgrounds. With over one hundred dedicated maintainers and thousands of contributors, our goal is to create the best, free, code learning platform on the web." # rubocop:disable Layout/LineLength
                  ]
                )
              end
          end +
            graphical_icon("contributing-header", category: "graphics", css_class: "hidden md:block") +
            tag.div('', class: 'decorations hidden lg:block')
        end
      end

      def nav
        tag.div(class: 'lg-container nav-container', data: { scrollable_container: true }) do
          tag.div(safe_join(tabs), class: 'tabs') +
            link_to(Exercism::Routes.docs_section_path(:building), class: "c-tab-2 guides") do
              graphical_icon(:guides) + tag.span("Contributing Help")
            end
        end
      end

      def tabs
        [
          link_to(
            Exercism::Routes.contributing_root_path,
            class: tab_class(:dashboard),
            data: scroll_into_view(:dashboard)
          ) do
            graphical_icon(:overview) +
              tag.span("Getting Started")
          end,

          link_to(
            Exercism::Routes.contributing_tasks_path,
            class: tab_class(:tasks),
            data: scroll_into_view(:tasks)
          ) do
            graphical_icon(:tasks) +
              tag.span("Explore tasks") +
              tag.span(number_with_delimiter(tasks_size), class: 'count')
          end,

          link_to(
            Exercism::Routes.contributing_contributors_path(period: :week),
            class: tab_class(:contributors),
            data: scroll_into_view(:contributors)
          ) do
            graphical_icon(:contributors) +
              tag.span("Contributors") +
              tag.span(number_with_delimiter(contributors_size), class: 'count')
          end

        ]
      end

      def tab_class(tab)
        "c-tab-2 #{'selected' if tab == selected_tab}"
      end

      def scroll_into_view(tab)
        { scroll_into_view: tab == selected_tab ? ScrollAxis::X : nil }
      end

      def guard!
        raise "Incorrect track nav tab" unless TABS.include?(selected_tab)
      end

      memoize
      def tasks_size
        number_with_delimiter(Github::Task.count)
      end

      memoize
      def contributors_size
        # TODO: (Optional) This might just be too slow to cope with, in which case consider caching it daily
        number_with_delimiter(User::ReputationPeriod.about_everything.forever.any_category.count)
      end
    end
  end
end
