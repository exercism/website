module Badges
  class NewYearsResolutionBadge < Badge
    seed "New Years Resolution",
      :rare,
      'new-years-resolution',
      'Awarded for submitting a solution on January 1st'

    def award_to?(user)
      user.solutions.
        where('DAYOFYEAR(solutions.created_at) = 1').
        exists?
    end

    def send_email_on_acquisition?
      true
    end
  end
end
