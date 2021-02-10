module Notifications
  class AcquiredBadgeNotification < Notification
    # TODO
    def url
      "#"
    end

    def i18n_params
      {
        badge_name: badge_name
      }
    end

    # TODO
    def image_type
      :avatar
    end

    # TODO
    def image_url
      user.avatar_url
    end

    def guard_params
      "Badge##{badge.id}"
    end

    private
    def badge_name
      badge.name
    end

    def badge
      params[:badge]
    end
  end
end
