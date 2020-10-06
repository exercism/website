module Badges
  class RookieBadge < Badge
    def name
      "Rookie"
    end

    def should_award?
      user.submissions.exists?
    end
  end
end
