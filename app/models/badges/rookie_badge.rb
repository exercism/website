module Badges
  class RookieBadge < Badge
    def name
      "Rookie"
    end

    def should_award?
      user.iterations.size > 0
    end
  end
end
