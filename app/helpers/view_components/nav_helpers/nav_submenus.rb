module ViewComponents
  module NavHelpers
    module NavSubmenus
      LEARN_SUBMENU = [
        {
          title: "Tracks",
          description: "Learn 99+ tracks for free forever",
          path: Exercism::Routes.tracks_path,
          icon: :tracks,
          content: ->(tag, instance) { instance.nav_dropdown_tracks_view(tag) }
        },
        {
          title: "Mentoring",
          description: "Get mentored by pros",
          path: Exercism::Routes.mentoring_path,
          icon: :mentoring,
          content: ->(tag, instance) { instance.nav_dropdown_mentoring_view(tag) }
        }
      ].freeze

      def nav_dropdown_tracks_view(tag)
        tag.div class: 'nav-dropdown-view-content' do
          "Track details"
        end
      end

      def nav_dropdown_mentoring_view(tag)
        tag.div class: 'nav-dropdown-view-content' do
          "mentoring details"
        end
      end
    end
  end
end
