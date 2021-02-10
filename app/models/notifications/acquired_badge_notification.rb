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
