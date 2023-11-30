module Badges
  class Completed12In23Badge < Badge
    seed "Completed #12in23 Challenge",
      :legendary,
      'badge-completed-12-in-23',
      'Completed and published all featured exercises in the #12in23 challenge'

    def award_to?(user)
      return false unless participant?(user)

      User::Challenges::FeaturedExercisesProgress12In23.(user).all? do |exercise_progress|
        exercise_progress[:earned_for].present?
      end
    end

    def send_email_on_acquisition? = true

    def participant?(user) = user.challenges.where(challenge_id: User::Challenge::CHALLENGE_12_IN_23).exists?
  end
end
