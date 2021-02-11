class User
  class AcquiredBadge
    class Create
      include Mandate

      initialize_with :user, :slug

      def call
        # Check to see if it exists already before
        # doing any other expensive things
        acquired_badge = User::AcquiredBadge.find_by(user: user, badge: badge)
        return acquired_badge if acquired_badge

        # Check if the badge should be awarded.
        # Raise an exception if not
        raise BadgeCriteriaNotFulfilledError unless badge.award_to?(user)

        # Build the badge
        begin
          User::AcquiredBadge.create!(
            user: user,
            badge: badge
          ).tap do |badge|
            Notification::Create.(user, :acquired_badge, { badge: badge })
          end

        # Guard against the race condition
        # and return the badge if it's been created
        # in parallel to this command
        rescue ActiveRecord::RecordNotUnique
          User::AcquiredBadge.find_by!(
            user: user,
            badge: badge
          )
        end
      end

      memoize
      def badge
        Badge.find_by_slug!(slug) # rubocop:disable Rails/DynamicFindBy
      end
    end
  end
end
