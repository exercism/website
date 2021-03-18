module ReactComponents
  module Mentoring
    class TryMentoringButton < ReactComponent
      def to_s
        super("mentoring-try-mentoring-button", { links: links })
      end

      private
      def links
        {
          choose_track_step: {
            tracks: Exercism::Routes.api_tracks_url
          },
          commit_step: {
            code_of_conduct: Exercism::Routes.code_of_conduct_url,
            intellectual_humility: "https://en.wikipedia.org/wiki/Intellectual_humility",
            registration: Exercism::Routes.api_mentoring_registration_url
          },
          congratulations_step: {
            video: "https://player.vimeo.com/video/121725838?title=0&byline=0&portrait=0",
            dashboard: Exercism::Routes.mentoring_queue_url
          }
        }
      end
    end
  end
end
