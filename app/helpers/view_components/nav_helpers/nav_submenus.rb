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

      DISCOVER_SUBMENU = [
        {
          title: "Community Videos",
          description: "Streaming, walkthroughs & more",
          path: Exercism::Routes.community_videos_path,
          icon: 'external-site-youtube',
          view: :community_content
        },

        {
          title: "Brief Introduction Series",
          description: "Erik introduces languages",
          path: Exercism::Routes.community_brief_introductions_path,
          icon: :'brief-introductions-gradient'
        },
        {
          title: "Interviews & Stories",
          description: "Get inspired by people's stories",
          path: Exercism::Routes.community_interviews_path,
          icon: 'interview-gradient'
        },

        {
          title: "Discord",
          description: "Chat & hang with the community",
          path: Exercism::Routes.discord_redirect_path,
          icon: 'external-site-discord-blue',
          view: :discord
        },
        {
          title: "Forum",
          description: "Dig deeper into topics",
          path: Exercism::Routes.forum_redirect_path,
          icon: :discourser,
          view: :forum
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
          title: "Contributors",
          description: "Meet the people behind Exercism",
          path: Exercism::Routes.contributing_contributors_path,
          icon: :contributors,
          icon_filter: "textColor6"
        }
      ].freeze

      MORE_SUBMENU = [
        {
          title: "SWAG",
          description: "Hoodies, stickers & more",
          path: 'https://swag.exercism.org',
          icon: :swag,
          icon_filter: "textColor6"
        },
        {
          title: "Insiders",
          description: "Our way of saying thank you",
          path: Exercism::Routes.insiders_path,
          icon: :insiders
        },
        {
          title: "About Exercism",
          description: "Learn about our organisation",
          path: Exercism::Routes.about_path,
          icon: :'exercism-face',
          icon_filter: "textColor6"
        },
        {
          title: "Donate",
          description: "Help support our mission",
          path: Exercism::Routes.donate_path,
          icon: :donate,
          icon_filter: "textColor6"
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
