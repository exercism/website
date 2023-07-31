module ReactComponents
  module Impact
    class TestimonialsList < ReactComponent
      initialize_with :params

      def to_s
        super("profile-testimonials-list", {
          request: {
            endpoint: Exercism::Routes.api_impact_testimonials_path,
            options: {
              endpoint: Exercism::Routes.api_impact_testimonials_url,
              query: params.slice(*AssembleImpactTestimonialsList.keys),
              initial_data: AssembleImpactTestimonialsList.(params)
            }
          },
          default_selected: params[:uuid] || nil
        })
      end
    end
  end
end
