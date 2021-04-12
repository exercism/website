module API
  class Mentoring::TestimonialsController < BaseController
    def index
      testimonials = ::Mentor::Testimonial::Retrieve.(
        mentor: current_user,
        page: params[:page],
        criteria: params[:criteria],
        track_slug: params[:track],
        order: params[:order],
        include_unrevealed: true
      )

      render json: SerializePaginatedCollection.(
        testimonials,
        serializer: SerializeMentorTestimonials
      )
    end

    def reveal
      # TODO
      testimonial = Mentor::Testimonial.find(params[:id])

      testimonial.update!(revealed: true)

      render json: {
        testimonial: SerializeMentorTestimonial.(testimonial)
      }
    end
  end
end
