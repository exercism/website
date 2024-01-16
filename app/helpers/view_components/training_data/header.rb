module ViewComponents
  module TrainingData
    class Header < ViewComponent
      initialize_with :selected_tab

      def to_s
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
              tag.span("Training Data")
          end
        end
      end

      def bottom
        tag.nav(class: "bottom") do
          tag.div(safe_join(tabs), class: 'tabs') +
            # TODO: update this path
            link_to(Exercism::Routes.docs_section_path(:mentoring), class: "c-tab-2 guides") do
              graphical_icon(:guides) + tag.span("Tagging Guides")
            end
        end
      end

      def tabs = [tags_tab]

      def tags_tab
        link_to(
          Exercism::Routes.training_data_root_path,
          class: tab_class(:tags)
        ) do
          graphical_icon(:overview) +
            tag.span("Tags")
        end
      end

      def tab_class(tab)
        "c-tab-2 #{'selected' if tab == selected_tab}"
      end
    end
  end
end
