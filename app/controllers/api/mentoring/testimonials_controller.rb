module API
  class Mentoring::TestimonialsController < BaseController
    before_action :use_testimonial, except: :index

    def index
      render json: AssembleTestimonialsList.(current_user, testimonial_params)
    end

    def reveal
      # TODO: Move to command and call User::ResetCache
      @testimonial.update!(revealed: true)

      render json: {
        testimonial: SerializeMentorTestimonial.(@testimonial)
      }
    end

    def destroy
      @testimonial.soft_destroy!

      render json: {
        testimonial: SerializeMentorTestimonial.(@testimonial)
      }
    end

    private
    def testimonial_params
      params.permit(*AssembleTestimonialsList.keys)
    end

    def use_testimonial
      @testimonial = current_user.mentor_testimonials.find_by(uuid: params[:uuid])
      return render_404(:mentor_testimonial_not_found) unless @testimonial
    end
  end
end
