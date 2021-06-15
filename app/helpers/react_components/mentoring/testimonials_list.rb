module ReactComponents
  module Mentoring
    class TestimonialsList < ReactComponent
      include Webpacker::Helper
      include ActionView::Helpers::AssetUrlHelper

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
            tracks: tracks
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
            "media/images/icons/all-tracks.svg",
            host: Rails.application.config.action_controller.asset_host
          )
        )
      end
    end
  end
end
