module Badges
  class AnybodyThereBadge < Badge
    seed "Anybody there?",
      :rare,
      'hello-world',
      'Completed "Hello, World!" in five languages'

    def award_to?(user, exercise:)
      return false unless exercise == 'hello-world'

      user.solutions.completed.joins(:exercise).
        where('exercises.slug': "hello-world").
        count >= 5
    end

    def send_email_on_acquisition?
      true
    end
  end
end
