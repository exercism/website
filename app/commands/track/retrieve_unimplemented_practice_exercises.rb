class Track::RetrieveUnimplementedPracticeExercises
  include Mandate

  initialize_with :track

  def call
    GenericExercise.active.where.not(slug: implemented_exercise_slugs + foregone_exercise_slugs)
  end

  private
  def implemented_exercise_slugs = track.practice_exercises.pluck(:slug)
  def foregone_exercise_slugs = track.git.foregone_exercises
end
