module Badges
  class MemberBadge < Badge
    seed "Member",
      :common,
      :logo,
      "Joined Exercism"

    def award_to?(_user)
      true
    end
  end
end
