module ViewComponents
  # The signed-in user menu's language picker. The header's LanguageSwitcher is
  # plain links, which suits a signed-out visitor; a signed-in user's locale
  # lives on their account, so each row posts to SettingsController instead.
  #
  # A <details> rather than a <select>: the rows carry a flag and both names,
  # and it opens, closes and handles Escape without JavaScript of its own.
  #
  # Only served languages appear; the "coming soon" list stays on
  # /settings/user_preferences.
  class UserMenuLanguageSwitcher < ViewComponent
    extend Mandate::Memoize

    def to_s
      return "" if languages.one?

      tag.details(class: "language-switcher") do
        summary + panel
      end
    end

    private
    def summary
      tag.summary(class: "language-current") do
        flag(current) + names(current) + graphical_icon("chevron-down", css_class: "language-chevron")
      end
    end

    def panel
      tag.div(class: "language-panel") do
        tag.ul(class: "language-group") { safe_join(languages.map { |language| option(language) }) }
      end
    end

    def option(language)
      current = language.code == I18n.locale.to_s

      tag.li do
        button_to(Exercism::Routes.update_locale_settings_path,
          method: :patch,
          params: { new_locale: language.code, return_to: request.fullpath },
          class: "language-option",
          form: { class: "language-form", data: { turbo: false } },
          "aria-current": (current ? "true" : nil)) do
          flag(language) + names(language) + check(current)
        end
      end
    end

    def check(current)
      return "".html_safe unless current

      graphical_icon("checkmark", css_class: "language-check")
    end

    # The endonym leads, so a speaker finds their own language first.
    def names(language)
      tag.span(class: "language-names") do
        tag.span(language.native, class: "language-native", lang: language.code) +
          tag.span(language.english, class: "language-english")
      end
    end

    def flag(language)
      image_tag("flags/3x2/#{language.flag}.svg", alt: "", "aria-hidden": true, class: "language-flag")
    end

    def current = languages.find { |language| language.code == I18n.locale.to_s } || languages.first

    memoize
    def languages = Locale::Languages.(I18n.locale)[:live]
  end
end
