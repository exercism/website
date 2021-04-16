module ReactComponents
  module Mentoring
    class TestimonialsList < ReactComponent
      include Webpacker::Helper
      include ActionView::Helpers::AssetUrlHelper

      def to_s
        super(
          "mentoring-testimonials-list",
          {
            request: {
              endpoint: Exercism::Routes.api_mentoring_testimonials_url,
              query: {
                track: nil
              },
              options: {
                initial_data: SerializePaginatedCollection.(
                  testimonials,
                  serializer: SerializeMentorTestimonials
                )
              }
            },
            tracks: tracks
          }
        )
      end

      private
      def testimonials
        ::Mentor::Testimonial::Retrieve.(mentor: current_user, include_unrevealed: true)
      end

      memoize
      def tracks
        tracks = ::Track.where(id: current_user.mentor_testimonials.
                                   joins(solution: :exercise).
                                   select(:track_id))
        output = tracks.map do |track|
          {
            title: track.title,
            slug: track.slug,
            icon_url: track.icon_url
          }
        end

        output.unshift(
          title: "All",
          slug: nil,
          icon_url: asset_pack_url(
            "media/images/icons/logo.svg",
            host: Rails.application.config.action_controller.asset_host
          )
        )
      end
    end
  end
end
