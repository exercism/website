class Solution::UnlockHelp
  include Mandate

  initialize_with :solution

  def call
    raise SolutionCannotBeUnlockedError unless solution.downloaded? || solution.submitted?

    @solution.update(unlocked_help: true)
  end
end
