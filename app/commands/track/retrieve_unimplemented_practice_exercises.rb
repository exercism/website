class Track::RetrieveUnimplementedPracticeExercises
  include Mandate

  initialize_with :track

  def call
    prob_specs_repo.active_exercise_slugs -
      track.practice_exercises.pluck(:slug) -
      track.git.foregone_exercises
  end

  private
  memoize
  def prob_specs_repo = Git::ProblemSpecifications.new
end
