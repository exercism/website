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
          title: "#48in24 Challenge",
          description: "A different challenge each week in 2024",
          path: Exercism::Routes.challenge_path('48in24'),
          icon: 'nav-12in23',
          view: :challenge_48in24 # rubocop:disable Naming/VariableNumber
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
          title: "Exercism Perks",
          description: "Offers & discounts from our partners",
          path: Exercism::Routes.perks_path,
          icon: 'perks-gradient'
        },

        {
          title: "Community Videos",
          description: "Streaming, walkthroughs & more",
          path: Exercism::Routes.community_videos_path,
          icon: 'external-site-youtube',
          view: :community_content
        },

        {
          title: "Brief Introduction Series",
          description: "Short language overviews",
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
          view: :discord,
          external: true
        },
        {
          title: "Forum",
          description: "Dig deeper into topics",
          path: Exercism::Routes.forum_redirect_path,
          icon: :discourser,
          view: :forum,
          external: true
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
        #   title: "Training Hub",
        #   description: "Help train Exercism's neural network",
        #   path: Exercism::Routes.training_data_root_path,
        #   icon: :robot,
        #   icon_filter: "textColor6"
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
          title: "Donate",
          description: "Help support our mission",
          path: Exercism::Routes.donate_path,
          icon: :donate,
          icon_filter: "textColor6"
        },
        {
          title: "About Exercism",
          description: "Learn about our organisation",
          path: Exercism::Routes.about_path,
          icon: :'exercism-face',
          icon_filter: "textColor6"
        },
        {
          title: "Our Impact",
          description: "Explore what we've achieved",
          path: Exercism::Routes.impact_about_path,
          icon: :report,
          icon_filter: "textColor6"
        },

        {
          title: "Insiders",
          description: "Our way of saying thank you",
          path: Exercism::Routes.insiders_path,
          icon: :insiders
        },
        {
          title: "SWAG",
          description: "Hoodies, stickers & more",
          path: 'https://swag.exercism.org',
          icon: :swag,
          icon_filter: "textColor6",
          external: true
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

      def nav_dropdown_challenge_48in24_view
        tag.div class: 'nav-dropdown-view-content' do
          render(template: "layouts/nav/48in24")
        end
      end
    end
  end
end
