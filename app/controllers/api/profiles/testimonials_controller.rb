class API::Profiles::TestimonialsController < API::Profiles::BaseController
  def index
    render json: AssembleProfileTestimonialsList.(@user, params)
  end
end
