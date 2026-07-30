module ViewComponents
  module NavHelpers
    module NavSubmenus
      LEARN_SUBMENU = [
        {
          title: -> { I18n.t("components.nav_submenus.learn.tracks.title") },
          description: -> { I18n.t("components.nav_submenus.learn.tracks.description") },
          path: Exercism::Routes.tracks_path,
          icon: 'nav-tracks',
          view: :tracks
        },
        {
          title: -> { I18n.t("components.nav_submenus.learn.coding_fundamentals.title") },
          description: -> { I18n.t("components.nav_submenus.learn.coding_fundamentals.description") },
          path: "https://jiki.io",
          icon: 'nav-coding-fundamentals',
          view: :coding_fundamentals
        },
        {
          title: -> { I18n.t("components.nav_submenus.learn.journey.title") },
          description: -> { I18n.t("components.nav_submenus.learn.journey.description") },
          path: Exercism::Routes.journey_path,
          icon: 'nav-journey',
          view: :journey
        },
        {
          title: -> { I18n.t("components.nav_submenus.learn.favorites.title") },
          description: -> { I18n.t("components.nav_submenus.learn.favorites.description") },
          path: Exercism::Routes.favorites_path,
          icon: 'nav-favorites',
          view: :favorites,
          is_new: true
        }
      ].freeze

      DISCOVER_SUBMENU = [
        {
          title: -> { I18n.t("components.nav_submenus.discover.perks.title") },
          description: -> { I18n.t("components.nav_submenus.discover.perks.description") },
          path: Exercism::Routes.perks_path,
          icon: 'perks-gradient'
        },

        {
          title: -> { I18n.t("components.nav_submenus.discover.community_content.title") },
          description: -> { I18n.t("components.nav_submenus.discover.community_content.description") },
          path: Exercism::Routes.community_videos_path,
          icon: 'external-site-youtube',
          view: :community_content
        },

        {
          title: -> { I18n.t("components.nav_submenus.discover.brief_introductions.title") },
          description: -> { I18n.t("components.nav_submenus.discover.brief_introductions.description") },
          path: Exercism::Routes.community_brief_introductions_path,
          icon: :'brief-introductions-gradient'
        },
        {
          title: -> { I18n.t("components.nav_submenus.discover.interviews.title") },
          description: -> { I18n.t("components.nav_submenus.discover.interviews.description") },
          path: Exercism::Routes.community_interviews_path,
          icon: 'interview-gradient'
        },

        {
          title: -> { I18n.t("components.nav_submenus.discover.discord.title") },
          description: -> { I18n.t("components.nav_submenus.discover.discord.description") },
          path: Exercism::Routes.discord_redirect_path,
          icon: 'external-site-discord-blue',
          view: :discord,
          external: true
        },
        {
          title: -> { I18n.t("components.nav_submenus.discover.forum.title") },
          description: -> { I18n.t("components.nav_submenus.discover.forum.description") },
          path: Exercism::Routes.forum_redirect_path,
          icon: :discourser,
          view: :forum,
          external: true
        }
      ].freeze

      CONTRIBUTE_SUBMENU = [
        {
          title: -> { I18n.t("components.nav_submenus.contribute.getting_started.title") },
          description: -> { I18n.t("components.nav_submenus.contribute.getting_started.description") },
          path: Exercism::Routes.contributing_root_path,
          icon: :overview,
          icon_filter: "textColor6"
        },
        {
          title: -> { I18n.t("components.nav_submenus.contribute.mentoring.title") },
          description: -> { I18n.t("components.nav_submenus.contribute.mentoring.description") },
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
          title: -> { I18n.t("components.nav_submenus.contribute.docs.title") },
          description: -> { I18n.t("components.nav_submenus.contribute.docs.description") },
          path: Exercism::Routes.docs_path,
          icon: :docs,
          icon_filter: "textColor6"
        },
        {
          title: -> { I18n.t("components.nav_submenus.contribute.contributors.title") },
          description: -> { I18n.t("components.nav_submenus.contribute.contributors.description") },
          path: Exercism::Routes.contributing_contributors_path,
          icon: :contributors,
          icon_filter: "textColor6"
        },
        {
          title: -> { I18n.t("components.nav_submenus.contribute.translators.title") },
          description: -> { I18n.t("components.nav_submenus.contribute.translators.description") },
          path: Exercism::Routes.new_localization_translator_path,
          icon: :world,
          is_new: true,
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
          title: -> { I18n.t("components.nav_submenus.more.donate.title") },
          description: -> { I18n.t("components.nav_submenus.more.donate.description") },
          path: Exercism::Routes.donate_path,
          icon: :donate,
          icon_filter: "textColor6"
        },
        {
          title: -> { I18n.t("components.nav_submenus.more.about.title") },
          description: -> { I18n.t("components.nav_submenus.more.about.description") },
          path: Exercism::Routes.about_path,
          icon: :'exercism-face',
          icon_filter: "textColor6"
        },
        {
          title: -> { I18n.t("components.nav_submenus.more.impact.title") },
          description: -> { I18n.t("components.nav_submenus.more.impact.description") },
          path: Exercism::Routes.impact_about_path,
          icon: :report,
          icon_filter: "textColor6"
        },
        {
          title: -> { I18n.t("components.nav_submenus.more.github_syncer.title") },
          description: -> { I18n.t("components.nav_submenus.more.github_syncer.description") },
          path: Exercism::Routes.settings_github_syncer_path,
          icon: 'feature-github-sync',
          icon_filter: "textColor6",
          is_new: true
        },

        {
          title: -> { I18n.t("components.nav_submenus.more.insiders.title") },
          description: -> { I18n.t("components.nav_submenus.more.insiders.description") },
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
          I18n.t("components.nav_submenus.views.mentoring_details")
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
