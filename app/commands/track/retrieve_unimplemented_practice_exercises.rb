class Track::RetrieveUnimplementedPracticeExercises
  include Mandate

  initialize_with :track

  def call
    prob_specs.active_exercises.map(&:slug) -
      track.practice_exercises.pluck(:slug) -
      track.git.foregone_exercises
  end

  private
  memoize
  def prob_specs = ProblemSpecifications.new
end
