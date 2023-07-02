module ViewComponents
  class Partner::Advert < ViewComponent
    include Mandate

    initialize_with advert: nil, track: nil, preview: false

    def to_s
      # Don't show adverts at all for crawlers
      return nil if request.is_crawler?

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
    def advert
      @advert || ::Partner::Advert.first
    end
  end
end
