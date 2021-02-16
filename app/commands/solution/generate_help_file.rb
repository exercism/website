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
      tests_intro_text = I18n.t("exercises.documents.tests_intro").strip

      <<~TEXT.strip
        ## #{tests_intro_text}

        #{tests_text}
      TEXT
    end

    def submitting
      submitting_solution_intro_text = I18n.t("exercises.documents.submitting_solution_intro").strip

      <<~TEXT.strip
        ## #{submitting_solution_intro_text}

        TODO
      TEXT
    end

    def help
      track_help_text = Markdown::Preprocess.(solution.track.git.help).strip
      help_intro_text = I18n.t("exercises.documents.help_intro").strip

      <<~TEXT.strip
        ## #{help_intro_text}

        TODO

        #{track_help_text}
      TEXT
    end
  end
end
