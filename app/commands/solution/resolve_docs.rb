# Which version of an exercise's instructions, introduction and hints a
# solution shows in the current locale.
#
# A solution pins the git sha it was started at and keeps showing those
# docs. Translations are filed by blob id, so an old version only resolves
# if its files are byte-identical to ones translated since launch. When
# they aren't, we show the translation of the exercise's latest version
# (flagged, so the page can say so and offer English or an update) rather
# than untranslated text.
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
