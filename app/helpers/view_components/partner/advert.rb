module ViewComponents
  class Partner::Advert < ViewComponent
    include Mandate

    initialize_with advert: nil, track: nil, preview: false

    def to_s
      return nil if request.is_crawler?

      render(
        template: "components/advert",
        locals: { advert: }
      ).tap do |_output|
        ::Partner::LogAdvertImpression.defer(
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
