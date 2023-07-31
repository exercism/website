module ReactComponents
  module Mentoring
    class TryMentoringButton < ReactComponent
      def initialize(
        text: "Try mentoring now",
        size: 'm',
        redirect_link: Exercism::Routes.mentoring_queue_url
      )
        super()

        @text = text
        @size = size
        @redirect_link = redirect_link
      end

      def to_s
        super("mentoring-try-mentoring-button", {
          text:,
          size:,
          links:
        })
      end

      private
      def links
        {
          choose_track_step: {
            tracks: Exercism::Routes.api_mentoring_tracks_url
          },
          commit_step: {
            code_of_conduct: Exercism::Routes.code_of_conduct_path,
            intellectual_humility: "https://en.wikipedia.org/wiki/Intellectual_humility",
            registration: Exercism::Routes.api_mentoring_registration_url
          },
          congratulations_step: {
            video: "https://player.vimeo.com/video/595885414?title=0&byline=0&portrait=0",
            dashboard: redirect_link
          }
        }
      end

      attr_reader :text, :size, :redirect_link
    end
  end
end
