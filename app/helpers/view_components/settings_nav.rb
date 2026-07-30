module ViewComponents
  class SettingsNav < ViewComponent
    extend Mandate::Memoize

    initialize_with :selected

    def to_s
      items = [
        item_for(I18n.t("components.settings_nav.account_settings"), :settings, :general),
        item_for(I18n.t("components.settings_nav.api_cli"), :api_cli_settings, :api_cli),
        item_for(I18n.t("components.settings_nav.integrations"), :integrations_settings, :integrations),
        item_for(I18n.t("components.settings_nav.github_syncer"), :settings_github_syncer, :github_syncer),
        item_for(I18n.t("components.settings_nav.preferences"), :user_preferences_settings, :preferences),
        item_for(I18n.t("components.settings_nav.communication_preferences"), :communication_preferences_settings,
          :communication),
        item_for(I18n.t("components.settings_nav.donations"), :donations_settings, :donations),
        item_for(I18n.t("components.settings_nav.insiders"), :insiders_settings, :insiders)
      ]

      tag.nav(class: "settings-nav") do
        tag.ul safe_join(items)
      end
    end

    def item_for(text, route, key)
      tag.li do
        key == selected ?
          tag.div(text, class: 'selected') :
          link_to(text, Exercism::Routes.send("#{route}_path"))
      end
    end
  end
end
