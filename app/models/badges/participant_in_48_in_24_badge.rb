module Badges
  class ParticipantIn48In24Badge < Badge
    seed "#48in24 Participant",
      :common,
      '48_in_24',
      'Participated in the #48in24 challenge and achieved a medal'

    def award_to?(user)
      exercises = User::Challenges::FeaturedExercisesProgress48In24.(user)
      exercises.any? { |e| e.status != :in_progress }
    end

    def send_email_on_acquisition? = true
  end
end
