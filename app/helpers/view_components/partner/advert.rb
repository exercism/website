module ViewComponents
  class Partner::Advert < ViewComponent
    include Mandate

    initialize_with advert: nil, track: nil, preview: false

    def to_s
      # Don't show adverts at all for crawlers
      return nil if request.is_crawler?
      return nil unless preview || show_advert?
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
      return @advert if @advert

      return unless track

      candidates = ::Partner::Advert.active.to_a
      candidates.sort_by! { rand }

      # rubocop:disable Style/CombinableLoops
      candidates.each do |candidate|
        next unless candidate.track_slugs

        if candidate.track_slugs.include?(track.slug)
          @advert = candidate
          return @advert
        end
      end

      candidates.each do |candidate|
        unless candidate.track_slugs
          @advert = candidate
          return @advert
        end
      end
      # rubocop:enable Style/CombinableLoops
    end

    def show_advert?
      !!advert
    end

    ALLOWED_DATES = [
      Date.new(2023, 8, 16)..Date.new(2023, 8, 21),
      Date.new(2023, 9, 14)..Date.new(2023, 9, 17),
      Date.new(2023, 10, 13)..Date.new(2023, 10, 16),
      Date.new(2023, 11, 3)..Date.new(2023, 11, 5)
    ].map(&:to_a).flatten.freeze
  end
end
