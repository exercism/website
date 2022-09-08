module ReactComponents
  module Profile
    class TestimonialsList < ReactComponent
      initialize_with :user, :params

      def to_s
        super("profile-testimonials-list", {
          request: {
            endpoint: Exercism::Routes.api_profile_testimonials_path(user.handle),
            options: {
              endpoint: Exercism::Routes.api_profile_testimonials_url(user),
              query: params.slice(*AssembleProfileTestimonialsList.keys),
              initial_data: AssembleProfileTestimonialsList.(user, params)
            }
          },
          default_selected: params[:uuid] || nil
        })
      end
    end
  end
end
