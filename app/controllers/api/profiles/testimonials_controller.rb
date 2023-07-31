module API::Profiles
  class TestimonialsController < BaseController
    def index
      render json: AssembleProfileTestimonialsList.(@user, params)
    end
  end
end
