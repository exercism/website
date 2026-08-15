module ViewComponents
  class Partner::Advert < ViewComponent
    include Mandate

    initialize_with advert: nil, track: nil, preview: false

    def to_s
      return nil unless show_advert?

      uuid = SecureRandom.hex

      render(
        template: "components/advert",
        locals: { advert:, uuid: }
      )
    end

    private
    memoize
    def advert
      @advert ||= ::Partner::Advert.for_track(track)
    end

    # Deliberately does not check request.is_crawler?. That check keyed the
    # rendered HTML to the User-Agent, which Cloudflare does not include in its
    # cache key, so whichever client happened to warm the cache decided whether
    # everyone else saw an advert. Nothing bills us for a render either: clicks
    # are what count, and Partner::AdvertsController still ignores crawlers.
    def show_advert?
      return true if preview
      return false unless advert
      return false if current_user&.hide_website_adverts?

      true
    end
  end
end
