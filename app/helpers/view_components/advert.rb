module ViewComponents
  class Advert < ViewComponent
    include Mandate

    initialize_with track: Mandate::NO_DEFAULT

    def to_s
      advert = ::Advert.first

      render(template: "components/advert", locals: { advert: })
    end
  end
end
