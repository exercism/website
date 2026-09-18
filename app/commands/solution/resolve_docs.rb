class Solution::ResolveDocs
  include Mandate

  Docs = Struct.new(:git_exercise, :for_newer_version) do
    delegate :instructions, :introduction, :hints, to: :git_exercise
    alias_method :for_newer_version?, :for_newer_version
  end

  initialize_with :solution

  def call
    return Docs.new(pinned, false) if translated?(pinned) || up_to_date? || !translated?(latest)

    Docs.new(latest, true)
  end

  private
  delegate :exercise, to: :solution

  def pinned = solution.git_exercise
  def up_to_date? = solution.git_sha == exercise.git_sha

  memoize
  def latest = Git::Exercise.for_solution(solution, git_sha: exercise.git_sha)

  def translated?(git_exercise)
    git_exercise.instructions_translated? && git_exercise.introduction_translated? && git_exercise.hints_translated?
  end
end
