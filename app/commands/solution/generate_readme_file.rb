class Solution
  class GenerateReadmeFile
    include Mandate

    initialize_with :solution

    def call
      'README'
    end
  end
end
