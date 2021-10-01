module ReactComponents
  module Mentoring
    class TestimonialsList < ReactComponent
      include Webpacker::Helper
      include ActionView::Helpers::AssetUrlHelper

      def self.platforms
        %i[facebook twitter reddit linkedin devto]
      end

      def initialize(params, platforms = self.class.platforms)
        @params = params
        @platforms = platforms

        super()
      end

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
            tracks: tracks,
            platforms: platforms
          }
        )
      end

      private
      attr_reader :params, :platforms

      def data
        AssembleTestimonialsList.(current_user, params)
      end

      memoize
      def tracks
        tracks = ::Track.where(id: current_user.mentor_testimonials.
                                   joins(solution: :exercise).
                                   select(:track_id))

        AssembleTracksForSelect.(tracks)
      end
    end
  end
end
