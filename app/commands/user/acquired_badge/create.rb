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
          ).tap do |uab|
            User::Notification::CreateEmailOnly.(user, :acquired_badge, user_acquired_badge: uab) if badge.send_email_on_acquisition?

            User::Notification::Create.(user, badge.notification_key, {}) if badge.notification_key.present?
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
