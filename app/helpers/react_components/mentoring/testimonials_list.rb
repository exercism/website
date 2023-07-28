module ReactComponents
  module Mentoring
    class TestimonialsList < ReactComponent
      include Propshaft::Helper

      initialize_with :params

      def to_s
        super(
          "mentoring-testimonials-list",
          {
            request: {
              endpoint: Exercism::Routes.api_mentoring_testimonials_url,
              query: params.slice(*AssembleTestimonialsList.keys),
              options: {
                initial_data: data
              }
            },
            tracks:,
            platforms: Exercism.share_platforms
          }
        )
      end

      private
      def data
        AssembleTestimonialsList.(current_user, params)
      end

      memoize
      def tracks
        tracks = ::Track.where(id: current_user.mentor_testimonials.
                                   joins(discussion: :request).
                                   select(:track_id))

        AssembleTracksForSelect.(tracks)
      end
    end
  end
end
