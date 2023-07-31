module Badges
  class AllYourBaseBadge < Badge
    seed "All your base",
      :rare,
      'all-your-base',
      'Completed the "All Your Base" exercise'

    def self.worth_queuing?(exercise:)
      exercise.slug == 'all-your-base'
    end

    def award_to?(user)
      user.solutions.completed.joins(:exercise).
        where('exercises.slug': 'all-your-base').
        any?
    end

    def send_email_on_acquisition? = true
  end
end
