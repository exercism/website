module Badges
  class SupporterBadge < Badge
    seed "Supporter",
      :rare,
      :supporter,
      "Donated to Exercism, helping fund free education for everyone"

    def award_to?(user)
      user.total_donated_in_cents.positive?
    end

    def send_email_on_acquisition?
      false
    end
  end
end
