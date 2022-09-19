module API::Impact
  class TestimonialsController < API::BaseController
    def index
      render json: AssembleImpactTestimonialsList.(params)
    end
  end
end
