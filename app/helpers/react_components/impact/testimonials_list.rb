module ReactComponents
  module Impact
    class TestimonialsList < ReactComponent
      initialize_with :params

      def to_s
        super("impact-testimonials-list", {
          request: {
            endpoint: Exercism::Routes.api_impact_testimonials_path,
            query: params.slice(*AssembleImpactTestimonialsList.keys),
            options: {
              endpoint: Exercism::Routes.api_impact_testimonials_url,
              initial_data: AssembleImpactTestimonialsList.(params)
            }
          },
          default_selected: params[:uuid] || nil
        })
      end
    end
  end
end
