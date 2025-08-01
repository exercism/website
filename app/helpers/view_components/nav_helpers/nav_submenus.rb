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
          title: "Coding Fundamentals",
          description: "The ultimate way to learn to code",
          path: Exercism::Routes.bootcamp_url(course: "coding-fundamentals"),
          icon: 'nav-coding-fundamentals',
          view: :coding_fundamentals
        },
        {
          title: "Front-end Fundamentals",
          description: "Learn the basics of front-end development",
          path: Exercism::Routes.bootcamp_url(course: "front-end-fundamentals"),
          icon: 'nav-front-end-fundamentals',
          view: :front_end_fundamentals
        },
        {
          title: "Your Journey",
          description: "Explore your Exercism journey",
          path: Exercism::Routes.journey_path,
          icon: 'nav-journey',
          view: :journey
        },
        {
          title: "Your Favorites",
          description: "Revisit your favorite solutions",
          path: Exercism::Routes.favorites_path,
          icon: 'nav-favorites',
          view: :favorites
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
        # {
        #   title: "GitHub Backup",
        #   description: "Use our automated GitHub Backup system",
        #   path: Exercism::Routes.settings_github_syncer_path,
        #   icon: 'github-syncer',
        #   category: "graphics",
        # },

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
          title: "GitHub Syncer",
          description: "Backup your solutions to GitHub",
          path: Exercism::Routes.settings_github_syncer_path,
          icon: 'feature-github-sync',
          icon_filter: "textColor6"
        },

        {
          title: "Insiders",
          description: "Our way of saying thank you",
          path: Exercism::Routes.insiders_path,
          icon: :insiders
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
