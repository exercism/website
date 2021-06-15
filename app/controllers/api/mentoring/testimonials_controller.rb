module API
  class Mentoring::TestimonialsController < BaseController
    def index
      render json: AssembleTestimonialsList.(current_user, testimonial_params)
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

    private
    def testimonial_params
      params.permit(*AssembleTestimonialsList.keys)
    end
  end
end
