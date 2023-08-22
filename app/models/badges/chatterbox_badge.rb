module Badges
  class ChatterboxBadge < Badge
    seed "Chatterbox",
      :common,
      :chatterbox,
      "Joined Exercism's Discord server"

    def award_to?(user) = user.discord_uid.present?

    def send_email_on_acquisition? = false
  end
end
