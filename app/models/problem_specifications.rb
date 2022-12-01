class ProblemSpecifications
  include Mandate

  memoize
  def exercises
    git.exercises.map do |exercise|
      ProblemSpecifications::Exercise.new(exercise.slug, repo: git.repo)
    end
  end

  memoize
  def active_exercises = exercises.reject(&:deprecated?)

  memoize
  def deprecated_exercises = exercises.select(&:deprecated?)

  private
  memoize
  def git = Git::ProblemSpecifications.new
end
