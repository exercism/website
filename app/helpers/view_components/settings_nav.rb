module ViewComponents
  class SettingsNav < ViewComponent
    extend Mandate::Memoize

    initialize_with :selected

    def to_s
      items = [
        item_for("Account settings", :settings, :general),
        item_for("API / CLI", :api_cli_settings, :api_cli),
        item_for("Integrations", :integrations_settings, :integrations),
        item_for("Preferences", :user_preferences_settings, :preferences),
        item_for("Communication Preferences", :communication_preferences_settings, :communication),
        item_for("Donations", :donations_settings, :donations)
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
