class Track::RetrieveUnimplementedPracticeExercises
  include Mandate

  initialize_with :track

  def call
    prob_specs.active_exercises.reject do |exercise|
      implemented_exercises.include?(exercise.slug) ||
        foregone_exercises.include?(exercise.slug)
    end
  end

  private
  memoize
  def prob_specs = ProblemSpecifications.new

  memoize
  def implemented_exercises = track.practice_exercises.pluck(:slug).to_set

  memoize
  def foregone_exercises = track.git.foregone_exercises.to_set
end
