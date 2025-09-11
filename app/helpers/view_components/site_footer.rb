module ViewComponents
  class SiteFooter < ViewComponent
    extend Mandate::Memoize

    def to_s
      Rails.cache.fetch(cache_key, expires_in: 1.day) do
        tag.footer(id: "site-footer") do
          parts = []
          parts << render(template: 'components/footer/external') unless user_signed_in?
          parts << render(template: 'components/footer/shared', locals: { locales: })
          safe_join(parts)
        end
      end
    end

    private
    def locales
      fullpath = request.fullpath

      links = supported_locales.map do |locale|
        link_to url_for_locale(locale, fullpath, add_loop_breaker_query_param: true), class: 'locale' do
          tag.span(flag_for_locale(locale), class: 'flag') +
            tag.span(I18n.t(:language_version, locale: locale))
        end
      end

      safe_join(links)
    end

    def cache_key
      Cache::KeyForFooter.(current_user)
    end
  end
end
