module Badges
  class SupporterBadge < Badge
    seed "Supporter",
      :rare,
      :supporter,
      "Donated to Exercism, helping fund free education"

    def award_to?(user) = user.total_donated_in_cents.positive?

    def send_email_on_acquisition? = false
  end
end
