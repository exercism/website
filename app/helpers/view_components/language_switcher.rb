module ViewComponents
  # The signed-out header's language picker.
  #
  # Each served locale is a plain link to the current page under that locale's
  # prefix, so a switch is a document load that re-resolves everything against
  # the new URL. The endonym leads, with the English name beneath, so a speaker
  # finds their own language without reading English first.
  #
  # The click also records the choice in the preference cookie, before the
  # navigation rather than on arrival: the redirect that sends a first-time
  # visitor to their language is decided before anything on the destination
  # page runs, so a cookie written on arrival comes too late and the visitor
  # oscillates. See setLocalePrefCookie on the JavaScript side.
  class LanguageSwitcher < ViewComponent
    def to_s
      return "" if I18n.available_locales.one?

      tag.details(class: "c-language-switcher") do
        summary + options
      end
    end

    private
    def summary
      tag.summary(class: "toggle", "aria-label": I18n.t("components.language_switcher.label")) do
        tag.span(name_for(I18n.locale).native, lang: I18n.locale) +
          graphical_icon("chevron-down")
      end
    end

    def options
      tag.ul(class: "options") do
        safe_join(I18n.available_locales.map { |locale| option(locale) })
      end
    end

    def option(locale)
      names = name_for(locale)

      tag.li do
        link_to(path_for_locale(locale), hreflang: locale, lang: locale,
          "data-locale-pref": locale, "aria-current": (locale == I18n.locale ? "true" : nil)) do
          tag.span(names.native, class: "native") + tag.span(names.english, class: "english")
        end
      end
    end

    def name_for(locale) = Locale::Name.(locale)
    def path_for_locale(locale) = view_context.path_for_locale(locale)
  end
end
