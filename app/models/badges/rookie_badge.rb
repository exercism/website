module Badges
  class RookieBadge < Badge
    def name
      "Rookie"
    end

    def should_award?
      user.iterations.exists?
    end
  end
end
