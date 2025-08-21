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
      ).tap do
        ::Partner::LogAdvertImpression.defer(
          uuid,
          advert, current_user, request.remote_ip,
          Time.current, request.path
        )
      end
    end

    private
    memoize
    def advert
      @advert ||= ::Partner::Advert.for_track(track)
    end

    def show_advert?
      return false if request.is_crawler?
      return true if preview
      return false unless advert
      return false if current_user&.hide_website_adverts?

      true
    end
  end
end
