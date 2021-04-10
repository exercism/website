module API
  class Mentoring::TestimonialsController < BaseController
    def index
      testimonials = ::Mentor::Testimonial::Retrieve.(
        mentor: current_user,
        page: params[:page],
        criteria: params[:criteria],
        track_slug: params[:track_slug],
        order: params[:order],
        include_unrevealed: true
      )

      render json: SerializePaginatedCollection.(
        testimonials,
        serializer: SerializeMentorTestimonials
      )
    end
  end
end
