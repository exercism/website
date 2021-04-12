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
      testimonial = current_user.mentor_testimonials.find_by(uuid: params[:id])
      return render_404(:mentor_testimonial_not_found) unless testimonial

      testimonial.update!(revealed: true)

      render json: {
        testimonial: SerializeMentorTestimonial.(testimonial)
      }
    end
  end
end
