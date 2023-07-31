class Solution::GenerateHelpFile
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
    tests_intro_text = I18n.t("exercises.documents.tests_intro").strip
    tests_text = Markdown::Render.(solution.track.git.tests, :text).strip

    <<~TEXT.strip
      ## #{tests_intro_text}

      #{tests_text}
    TEXT
  end

  def submitting
    submitting_solution_intro_text = I18n.t("exercises.documents.submitting_solution_intro").strip

    submitting_solution_text = I18n.t("exercises.documents.submitting_solution",
      solution_file_paths: solution.exercise.git.solution_filepaths.join(" ")).strip

    <<~TEXT.strip
      ## #{submitting_solution_intro_text}

      #{submitting_solution_text}
    TEXT
  end

  def help
    help_intro_text = I18n.t("exercises.documents.help_intro").strip

    help_text = I18n.t("exercises.documents.help",
      track_title: solution.track.title, track_slug: solution.track.slug).strip

    track_help_text = Markdown::Render.(solution.track.git.help, :text).strip

    <<~TEXT.strip
      ## #{help_intro_text}

      #{help_text}

      #{track_help_text}
    TEXT
  end
end
