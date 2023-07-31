module Badges
  class WhateverBadge < Badge
    seed "Whatever",
      :common,
      'whatever',
      'Completed the "Bob" exercise'

    def self.worth_queuing?(exercise:)
      exercise.slug == 'bob'
    end

    def award_to?(user)
      user.solutions.completed.joins(:exercise).
        where('exercises.slug': 'bob').
        any?
    end

    def send_email_on_acquisition? = true
  end
end
