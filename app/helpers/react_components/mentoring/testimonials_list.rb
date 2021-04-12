module ReactComponents
  module Mentoring
    class TestimonialsList < ReactComponent
      def to_s
        super(
          "mentoring-testimonials-list",
          {
            request: {
              endpoint: Exercism::Routes.api_mentoring_testimonials_url,
              query: {
                track: tracks.first.slug
              },
              options: {
                initial_data: SerializePaginatedCollection.(
                  testimonials,
                  serializer: SerializeMentorTestimonials
                )
              }
            },
            tracks: tracks.map do |track|
              {
                title: track.title,
                slug: track.slug,
                icon_url: track.icon_url
              }
            end
          }
        )
      end

      private
      def testimonials
        ::Mentor::Testimonial::Retrieve.(mentor: current_user, include_unrevealed: true)
      end

      def tracks
        current_user.mentored_tracks
      end
    end
  end
end
