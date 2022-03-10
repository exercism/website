module Badges
  class WhateverBadge < Badge
    seed "Whatever",
      :common,
      'whatever',
      'Awarded for completing the "Bob" exercise'

    def award_to?(user)
      user.solutions.completed.joins(:exercise).
        where('exercises.slug': 'bob').
        any?
    end

    def send_email_on_acquisition?
      true
    end
  end
end
