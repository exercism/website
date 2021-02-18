module Badges
  class RookieBadge < Badge
    seed "Rookie",
      :common,
      :editor,
      "Submitted an exercise"

    def award_to?(user)
      user.submissions.exists?
    end
  end
end
