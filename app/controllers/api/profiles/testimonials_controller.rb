module API
  class Profiles::TestimonialsController < BaseController
    before_action :use_user

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

    private
    def use_user
      @user = User.find_by!(handle: params[:profile_id])

      # TOOD: Handle and test this properly
      raise unless @user.profile
    end
  end
end
