module ViewComponents
  module NavHelpers
    module NavSubmenus
      LEARN_SUBMENU = [
        {
          title: "Language Tracks",
          description: "Upskill in 65+ languages",
          path: Exercism::Routes.tracks_path,
          icon: :tracks,
          view: :tracks
        },

        {
          title: "Mentoring",
          description: "Get mentored by pros",
          path: Exercism::Routes.mentoring_path,
          icon: :mentoring,
          view: :mentoring
        }
      ].freeze

      CONTRIBUTE_SUBMENU = [
        {
          title: "Getting started",
          description: "How you can help us build Exercism",
          path: Exercism::Routes.contributing_root_path,
          icon: :overview,
          view: :tracks
        },
        {
          title: "Mentoring",
          description: "Help ",
          path: Exercism::Routes.mentoring_path,
          icon: :mentoring,
          view: :mentoring
        },
        {
          title: "Explore tasks",
          description: nil,
          path: Exercism::Routes.contributing_tasks_path,
          icon: :tasks,
          view: :mentoring
        },
        {
          title: "Contributors",
          description: nil,
          path: Exercism::Routes.contributing_contributors_path,
          icon: :contributors,
          view: :mentoring
        }
      ].freeze

      COMMUNITY_SUBMENU = [
        {
          title: "Forum",
          description: "How you can help us build Exercism",
          path: Exercism::Routes.forum_redirect_path,
          icon: :discourser
        },
        {
          title: "Discord",
          description: nil,
          path: Exercism::Routes.discord_redirect_path,
          icon: "feature-discord"
        },
        {
          title: "YouTube",
          description: nil,
          path: Exercism::Routes.youtube_redirect_path,
          icon: 'feature-youtube'
        },
        {
          title: "Twitch",
          description: nil,
          path: Exercism::Routes.twitch_redirect_path,
          icon: :contributors
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
