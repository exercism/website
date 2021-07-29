module Badges
  class MemberBadge < Badge
    seed "Member",
      :common,
      :logo,
      "Awarded for joining Exercism"

    def award_to?(_user)
      true
    end
  end
end
