class User
  class AcquireBadge
    include Mandate

    initialize_with :user, :badge

    def call
      User::Badge.create_or_find_by!(user: user, badge: badge).tap do |user_badge|
        if user_badge.just_created?
          Notification::Create.(user, :acquired_badge, {user_badge: user_badge})
        end
      end
    end
  end
end
