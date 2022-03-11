module Badges
  class AllYourBaseBadge < Badge
    seed "All your base are belong to us",
      :rare,
      'all-your-base',
      'Awarded for completing the "All Your Base" exercise'

    def award_to?(user)
      user.solutions.completed.joins(:exercise).
        where('exercises.slug': 'all-your-base').
        any?
    end

    def send_email_on_acquisition?
      true
    end
  end
end
