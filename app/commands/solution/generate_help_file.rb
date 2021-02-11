class Solution
  class GenerateHelpFile
    include Mandate

    initialize_with :solution

    def call
      'HELP'
    end
  end
end
