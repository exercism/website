module Badges
  class NewYearsResolutionBadge < Badge
    seed "New Year's resolution",
      :rare,
      'new-years-resolution',
      'Submitted an iteration on January 1st'

    def self.worth_queuing?(iteration:)
      [1, 2, 365, 366].include?(iteration.created_at.yday)
    end

    def award_to?(user)
      user.iterations.
        where('DAYOFYEAR(iterations.created_at) IN (1, 2, 365, 366)').
        exists?
    end

    def send_email_on_acquisition? = true
  end
end
