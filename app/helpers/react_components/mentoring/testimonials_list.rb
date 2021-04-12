module ReactComponents
  module Mentoring
    class TestimonialsList < ReactComponent
      def to_s
        super(
          "mentoring-testimonials-list",
          {
            request: {
              endpoint: Exercism::Routes.api_mentoring_testimonials_url,
              options: {
                initial_data: SerializePaginatedCollection.(
                  testimonials,
                  serializer: SerializeMentorTestimonials
                )
              }
            }
          }
        )
      end

      private
      def testimonials
        ::Mentor::Testimonial::Retrieve.(mentor: current_user, include_unrevealed: true)
      end
    end
  end
end
