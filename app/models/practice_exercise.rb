class PracticeExercise < Exercise
  def self.that_practice(concept)
    joins(:exercise_prerequisites).
      where('exercise_prerequisites.track_concept_id': concept)
  end

  delegate :introduction, :instructions, to: :git
end
