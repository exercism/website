class Solution
  class GenerateHintsFile
    include Mandate

    initialize_with :solution

    def call
      solution.git_exercise.hints
    end
  end
end
