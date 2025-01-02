module Badges
  class PaavoNurmiBadge < Badge
    seed "Paavo Nurmi",
      :ultimate,
      'paavo-nurmi',
      'Earned 48 gold or silver medals in the #48in24 challenge'

    def award_to?(user)
      exercises = User::Challenges::FeaturedExercisesProgress48In24.(user)
      exercises.none? { |e| e.status == :in_progress } &&
        exercises.none? { |e| e.status == :bronze }
    end

    def send_email_on_acquisition? = true
  end
end
