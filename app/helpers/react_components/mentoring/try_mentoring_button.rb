module ReactComponents
  module Mentoring
    class TryMentoringButton < ReactComponent
      def to_s
        super("mentoring-try-mentoring-button", { links: links })
      end

      private
      def links
        { tracks: Exercism::Routes.api_tracks_url }
      end
    end
  end
end
