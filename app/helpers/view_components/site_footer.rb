module ViewComponents
  class SiteFooter < ViewComponent
    extend Mandate::Memoize

    def to_s
      # Rails.cache.fetch(cache_key, expires_in: 1.day) do
      tag.footer(id: "site-footer") do
        parts = []
        parts << render(template: 'components/footer/external') unless user_signed_in?
        parts << render(template: 'components/footer/shared')
        safe_join(parts)
      end
      # end
    end

    private
    def cache_key
      Cache::KeyForFooter.(current_user)
    end
  end
end
