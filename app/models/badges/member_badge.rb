module Badges
  class MemberBadge < Badge
    seed "Member",
      :common,
      :logo,
      "Joined Exercism"

    def award_to?(_user)
      true
    end

    def send_email_on_acquisition?
      false
    end

    def percentage_awardees
      100
    end
  end
end
