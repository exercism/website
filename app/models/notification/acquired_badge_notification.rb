class Notification
  class AcquiredBadgeNotification < Notification
    def i18n_params
      {
        badge_name: badge_name
      }
    end

    def guard_params
      "UserBadge##{user_badge.id}"
    end

    private
    def badge_name
      badge.name
    end

    def badge
      user_badge.badge
    end

    def user_badge
      params[:user_badge]
    end
  end
end

