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

      true
    end

    ALLOWED_DATES = [
      Date.new(2023, 8, 16)..Date.new(2023, 8, 21),
      Date.new(2023, 9, 14)..Date.new(2023, 9, 17),
      Date.new(2023, 10, 13)..Date.new(2023, 10, 16),
      Date.new(2023, 11, 3)..Date.new(2023, 11, 5)
    ].map(&:to_a).flatten.freeze
  end
end
