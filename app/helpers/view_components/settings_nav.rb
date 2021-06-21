module ViewComponents
  class SettingsNav < ViewComponent
    extend Mandate::Memoize

    initialize_with :selected

    def to_s
      items = [
        item_for("Account settings", "#", :general),
        item_for("API / CLI", "#", :api),
        item_for("Preferences", "#", :preferences),
        item_for("Communication Preferences", "#", :communication)
      ]

      tag.nav(class: "settings-nav") do
        tag.ul safe_join(items)
      end
    end

    def item_for(text, link, key)
      tag.li do
        key == selected ?
          tag.div(text, class: 'selected') :
          link_to(text, link)
      end
    end
  end
end
