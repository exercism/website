class Solution
  class UnlockHelp
    include Mandate

    initialize_with :solution

    def call
      raise SolutionHasNoIterationsError unless solution.iterated?

      @solution.update(unlocked_help: true)
    end
  end
end
