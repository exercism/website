module ViewComponents
  # The signed-out header's language picker.
  #
  # Each served locale is a plain link to the current page under that locale's
  # prefix, so a switch is a document load that re-resolves everything against
  # the new URL. The endonym leads, with the English name beneath, so a speaker
  # finds their own language without reading English first. The languages we do
  # not serve yet follow, disabled, so the breadth of the translation effort is
  # visible before any of it ships.
  #
  # The click also records the choice in the preference cookie, before the
  # navigation rather than on arrival: the redirect that sends a first-time
  # visitor to their language is decided before anything on the destination
  # page runs, so a cookie written on arrival comes too late and the visitor
  # oscillates. See setLocalePrefCookie on the JavaScript side.
  class LanguageSwitcher < ViewComponent
    extend Mandate::Memoize

    def to_s
      return "" if I18n.available_locales.one?

      tag.details(class: "c-language-switcher") do
        summary + options
      end
    end

    private
    def summary
      tag.summary(class: "toggle", "aria-label": I18n.t("components.language_switcher.label")) do
        flag(current) + graphical_icon("chevron-down")
      end
    end

    def options
      tag.div(class: "options") do
        tag.ul(class: "group") { safe_join(live.map { |language| option(language) }) } +
          coming_soon_heading +
          coming_soon_group
      end
    end

    def coming_soon_heading
      return "".html_safe if coming_soon.empty?

      tag.p(I18n.t("components.language_switcher.coming_soon"), class: "group-heading")
    end

    def coming_soon_group
      return "".html_safe if coming_soon.empty?

      tag.ul(class: "group") { safe_join(coming_soon.map { |language| coming_soon_option(language) }) }
    end

    def option(language)
      tag.li do
        link_to(path_for_locale(language.code), class: "option", hreflang: language.code,
          "data-locale-pref": language.code,
          "aria-current": (language.code == I18n.locale.to_s ? "true" : nil)) do
          flag(language) + names(language)
        end
      end
    end

    def coming_soon_option(language)
      tag.li do
        tag.span(class: "option --disabled") do
          flag(language) + names(language) +
            tag.span(I18n.t("components.language_switcher.coming_soon_badge"), class: "badge")
        end
      end
    end

    def names(language)
      tag.span(class: "names") do
        tag.span(language.native, class: "native", lang: language.code) +
          tag.span(language.english, class: "english")
      end
    end

    def flag(language)
      image_tag("flags/3x2/#{language.flag}.svg", alt: "", "aria-hidden": true, class: "flag")
    end

    def current = live.find { |language| language.code == I18n.locale.to_s } || live.first
    def live = languages[:live]
    def coming_soon = languages[:coming_soon]

    memoize
    def languages = Locale::Languages.(I18n.locale)

    def path_for_locale(locale) = view_context.path_for_locale(locale)
  end
end
