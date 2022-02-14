module API::Profiles
  class TestimonialsController < BaseController
    def index
      render json: AssembleProfileTestimonialsList.(@user)
    end
  end
end
