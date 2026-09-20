module ViewComponents
  # "This page is in English. View it in magyar."
  #
  # Rendered server-side, in the OFFERED language rather than the page's, so
  # the one person it is addressed to can read it. Dismissal is remembered per
  # offered language in localStorage (see locale-banner.ts).
  #
  # Nothing is offered to a client that sends no Accept-Language, which is what
  # keeps crawlers out of it, and nothing is offered to anyone already being
  # served the language they would be offered.
  class LocaleBanner < ViewComponent
    def to_s
      return "" if offered.nil?

      mark_response_private!
      current = I18n.locale

      I18n.with_locale(offered) do
        tag.div(class: "c-locale-banner", lang: offered, dir: Locale::Direction.(offered),
          "data-locale-banner": offered) do
          tag.span(copy("pre", current: name_for(current))) + switch_link + dismiss_button
        end
      end
    end

    private
    def switch_link
      link_to(copy("link", offered: name_for(offered)), view_context.path_for_locale(offered),
        hreflang: offered, "data-locale-pref": offered)
    end

    def dismiss_button
      tag.button(copy("dismiss"), type: "button", class: "dismiss", "data-locale-banner-dismiss": true)
    end

    # The banner varies by Accept-Language, so the response it sits in can never
    # be a shared cache entry.
    def mark_response_private!
      controller.response.headers["Cache-Control"] = "private, no-store"
      controller.response.headers["Vary"] = "Accept-Language, Cookie"
    end

    # The language to pitch, or nil for no banner.
    #
    # Signed in, that is the account's own locale: it is authoritative, and the
    # page is already being served in it unless the URL says otherwise. Signed
    # out, a stated preference is what we echo back, since pitching a browser
    # guess over someone's own choice is just nagging. Otherwise it is the
    # first supported browser language, and a client with no Accept-Language at
    # all gets nothing.
    memoize
    def offered
      candidate = offered_candidate
      candidate unless candidate.nil? || candidate == I18n.locale
    end

    def offered_candidate
      return Locale::Normalize.(current_user.locale) || I18n.default_locale if user_signed_in?

      chosen = Locale::Normalize.(cookies[Locale::PREF_COOKIE_NAME])
      return chosen if chosen
      return nil if accept_language.blank?

      Locale::FromAcceptLanguage.(accept_language) || I18n.default_locale
    end

    def accept_language = request.headers["Accept-Language"]
    def name_for(locale) = Locale::Name.(locale).native
    def cookies = controller.send(:cookies)
    def copy(key, **) = I18n.t("components.locale_banner.#{key}", **)
  end
end
