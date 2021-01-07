module Badges
  class MemberBadge < Badge
    badge "Member",
      :common,
      :logo,
      "Joined Exercism"

    def should_award?
      true
    end
  end
end
