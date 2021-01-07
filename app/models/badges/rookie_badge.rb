module Badges
  class RookieBadge < Badge
    badge "Rookie",
      :common,
      :editor,
      "Submitted an exercise"

    def should_award?
      user.submissions.exists?
    end
  end
end
