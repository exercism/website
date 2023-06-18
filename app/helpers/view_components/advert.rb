module ViewComponents
  class Advert < ViewComponent
    include Mandate

    initialize_with advert: nil, track: nil, preview: false

    def to_s
      render(
        template: "components/advert",
        locals: { advert: }
      ).tap do |output|
        # Advert::LogImpression.(advert)
      end
    end

    private
    def advert
      @advert || Advert.first
    end
  end
end
