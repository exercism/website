module Badges
  class LarisaLatyninaBadge < Badge
    seed "Larisa Latynina",
      :rare,
      'larisa-latynina',
      'Earned 48 medals in the #48in24 challenge'

    def award_to?(user)
      exercises = User::Challenges::FeaturedExercisesProgress48In24.(user)
      exercises.none? { |e| e.status == :in_progress }
    end

    def send_email_on_acquisition? = true
  end
end
