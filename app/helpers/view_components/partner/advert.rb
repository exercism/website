module ViewComponents
  class Partner::Advert < ViewComponent
    include Mandate

    initialize_with advert: nil, track: nil, preview: false

    def to_s
      # Don't show adverts at all for crawlers
      return nil if request.is_crawler?
      return nil unless preview || (track && %w[javascript python java].include?(track.slug))
      return nil unless preview || Time.current.on_weekend? || Date.current == Date.new(2023, 8, 15)
      return nil unless advert

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
      @advert || ::Partner::Advert.active.first
    end
  end
end
