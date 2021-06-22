module ReactComponents
  module Journey
    class BadgesSection < ReactComponent
      def to_s
        super("journey-badges-section", {
          badges: SerializeUserAcquiredBadges.(current_user.acquired_badges.revealed),
          links: {
            badges: Exercism::Routes.badges_journey_url
          }
        })
      end
    end
  end
end
