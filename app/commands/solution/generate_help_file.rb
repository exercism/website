class Solution
  class GenerateHelpFile
    include Mandate

    initialize_with :solution

    def call
      "# Help

## Running the tests

#{track_tests}

## Submitting your solution

#{exercism_submit_solution}

## Need to get help?

#{exercism_help}

#{track_help}"
    end

    private
    def track_tests
      Markdown::Preprocess.(solution.track.git.tests, remove_level_one_headings: true)
    end

    def track_help
      Markdown::Preprocess.(solution.track.git.help, remove_level_one_headings: true)
    end

    def exercism_submit_solution
      "TODO"
    end

    def exercism_help
      "TODO"
    end
  end
end
