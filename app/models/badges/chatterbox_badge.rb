module Badges
  class ChatterboxBadge < Badge
    seed "Chatterbox",
      :common,
      :chatterbox,
      "Linked your Exercism account to Discord"

    def award_to?(user) = user.discord_uid.present?

    def send_email_on_acquisition? = false
  end
end
