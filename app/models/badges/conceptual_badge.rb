module Badges
  class ConceptualBadge < Badge
    seed "Conceptual",
      :ultimate,
      :conceptual,
      "Completed all learning exercises in a track"

    def self.worth_queuing?(exercise:)
      exercise.type == 'ConceptExercise'
    end

    def award_to?(user)
      user.user_tracks.joins(:track).
        where(tracks: { active: true, course: true }).
        any? { |ut| ut.completed_concept_exercises_percentage == 100 }
    end

    def send_email_on_acquisition? = true
  end
end
