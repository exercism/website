module Badges
  class NewYearsResolutionBadge < Badge
    seed "New Year's resolution",
      :rare,
      'new-years-resolution',
      'Submitted a solution on January 1st'

    def award_to?(_user, day_of_year:)
      day_of_year == 1
    end

    def send_email_on_acquisition?
      true
    end
  end
end
