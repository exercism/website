module Badges
  class LackadaisicalBadge < Badge
    seed "Lackadaisical",
      :ultimate,
      'lackadaisical',
      'Completed the "Bob" exercise in five languages'

    def award_to?(user, exercise:)
      return false unless exercise == 'bob'

      user.solutions.completed.joins(:exercise).
        where('exercises.slug': 'bob').
        count >= 5
    end

    def send_email_on_acquisition?
      true
    end
  end
end
