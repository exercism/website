module Badges
  class RookieBadge < Badge
    seed "Rookie",
      :common,
      :editor,
      "Submitted an exercise"

    def award_to?(user) = user.iterations.exists?

    def send_email_on_acquisition? = false
  end
end
