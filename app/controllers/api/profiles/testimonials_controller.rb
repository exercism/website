module API::Profiles
  class TestimonialsController < BaseController
    def index
      testimonials = ::Mentor::Testimonial::Retrieve.(
        mentor: @user,
        page: params[:page],
        criteria: params[:criteria],
        track_slug: params[:track_slug],
        order: params[:order],
        include_unrevealed: false
      )

      render json: SerializePaginatedCollection.(
        testimonials,
        serializer: SerializeMentorTestimonials
      )
    end
  end
end
