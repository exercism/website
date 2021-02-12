class Solution
  class GenerateHelpFile
    include Mandate

    initialize_with :solution

    def call
      <<~TEXT.strip
        # Help

        #{tests}

        #{submitting}

        #{help}
      TEXT
    end

    private
    def tests
      tests_text = Markdown::Preprocess.(solution.track.git.tests).strip

      <<~TEXT.strip
        ## Running the tests

        #{tests_text}
      TEXT
    end

    def submitting
      <<~TEXT.strip
        ## Submitting your solution

        TODO
      TEXT
    end

    def help
      track_help_text = Markdown::Preprocess.(solution.track.git.help).strip

      <<~TEXT.strip
        ## Need to get help?

        TODO

        #{track_help_text}
      TEXT
    end
  end
end
