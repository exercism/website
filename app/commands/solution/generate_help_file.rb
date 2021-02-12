class Solution
  class GenerateHelpFile
    include Mandate

    initialize_with :solution

    def call
      <<~HELP.strip
        # Help

        #{tests}

        #{submitting}

        #{help}
      HELP
    end

    private
    def tests
      tests_text = Markdown::Preprocess.(solution.track.git.tests).strip
      "## Running the tests\n\n#{tests_text}"
    end

    def submitting
      "## Submitting your solution\n\nTODO"
    end

    def help
      track_help_text = Markdown::Preprocess.(solution.track.git.help).strip
      "## Need to get help?\n\nTODO\n\n#{track_help_text}"
    end
  end
end
