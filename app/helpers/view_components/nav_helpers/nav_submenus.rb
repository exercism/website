module ViewComponents
  module NavHelpers
    module NavSubmenus
      LEARN_SUBMENU = [
        {
          title: "Language Tracks",
          description: "Upskill in 65+ languages",
          path: Exercism::Routes.tracks_path,
          icon: 'nav-tracks',
          view: :tracks
        },

        {
          title: "#12in23 Challenge",
          description: "Try out 12 languages in 2023",
          path: Exercism::Routes.challenge_path('12in23'),
          icon: 'nav-12in23',
          view: :challenge_12in23 # rubocop:disable Naming/VariableNumber
        },

        {
          title: "Your Journey",
          description: "Explore your Exercism journey",
          path: Exercism::Routes.journey_path,
          icon: 'nav-journey',
          view: :journey
        }
      ].freeze

      CONTRIBUTE_SUBMENU = [
        {
          title: "Getting started",
          description: "How you can help Exercism",
          path: Exercism::Routes.contributing_root_path,
          icon: :overview,
          icon_filter: "textColor6"
        },
        {
          title: "Mentoring",
          description: "Support others as they learn",
          path: Exercism::Routes.mentoring_path,
          icon: :mentoring,
          icon_filter: "textColor6"
        },
        # {
        #   title: "Explore tasks",
        #   description: nil,
        #   path: Exercism::Routes.contributing_tasks_path,
        #   icon: :tasks,
        #   view: :mentoring
        # },

        {
          title: "Docs",
          description: "Everything you need to help",
          path: Exercism::Routes.docs_path,
          icon: :docs,
          icon_filter: "textColor6"
        },
        {
          title: "Insiders",
          description: "Our way of saying thank you",
          path: Exercism::Routes.insiders_path,
          icon: :insiders
        },
        {
          title: "Contributors",
          description: "The people behind Exercism",
          path: Exercism::Routes.contributing_contributors_path,
          icon: :contributors,
          icon_filter: "textColor6"
        }
      ].freeze

      COMMUNITY_SUBMENU = [
        {
          title: "Forum",
          description: "In-depth discussions",
          path: Exercism::Routes.forum_redirect_path,
          icon: :discourser,
          view: :forum
        },
        {
          title: "Discord",
          description: "Chat live to the community",
          path: Exercism::Routes.discord_redirect_path,
          icon: 'external-site-discord-blue',
          view: :discord
        },
        {
          title: "Community Content",
          description: "1,000s of community videos",
          path: Exercism::Routes.youtube_redirect_path,
          icon: 'external-site-youtube',
          view: :community_content
        },
        {
          title: "Community Stories",
          description: "By inspired by others",
          path: Exercism::Routes.youtube_redirect_path,
          icon: 'megaphone',
          icon_filter: "textColor6",
          view: :community_stories
        }
      ].freeze

      def nav_dropdown_tracks_view
        tag.div class: 'nav-dropdown-view-content' do
        end
      end

      def nav_dropdown_mentoring_view
        tag.div class: 'nav-dropdown-view-content' do
          "mentoring details"
        end
      end

      def nav_dropdown_challenge_12in23_view
        tag.div class: 'nav-dropdown-view-content' do
          render(template: "layouts/nav/12in23")
        end
      end
    end
  end
end
