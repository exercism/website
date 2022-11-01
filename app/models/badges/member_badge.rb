module Badges
  class MemberBadge < Badge
    seed "Member",
      :common,
      :logo,
      "Joined Exercism"

    def award_to?(_user) = true
    def send_email_on_acquisition? = false

    def percentage_awardees = 100
  end
end
