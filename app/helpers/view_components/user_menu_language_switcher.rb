module ViewComponents
  # The signed-in user menu's language picker.
  #
  # The header's LanguageSwitcher is a set of plain links, which is right for a
  # signed-out visitor: nothing to save, so the URL carries the whole choice.
  # A signed-in user's locale is read off their account instead, so each row
  # here posts to LocaleController, which saves it and then redirects to this
  # same page under the new locale.
  #
  # A <details> rather than a <select>: the rows carry a flag and both names,
  # which a native option list cannot render. It also opens and closes, and
  # closes on Escape, without any JavaScript of its own.
  #
  # Only the served languages appear. The menu is a navigation surface with a
  # finite amount of room, so the long "coming soon" list stays on
  # /settings/user_preferences, which the Settings row above leads to.
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
        button_to(Exercism::Routes.locale_path,
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

    # The endonym leads, so a speaker finds their own language without reading
    # English first; the English name follows for everyone else.
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
