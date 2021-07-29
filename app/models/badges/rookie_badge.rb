module Badges
  class RookieBadge < Badge
    seed "Rookie",
      :common,
      :editor,
      "Awarded for submitting an exercise"

    def award_to?(user)
      user.submissions.exists?
    end
  end
end
