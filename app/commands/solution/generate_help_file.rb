class Solution::GenerateHelpFile
  include Mandate

  initialize_with :solution
  delegate :track, :exercise, to: :solution

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
    header = I18n.t("exercises.documents.tests_header").strip
    contents = Markdown::Render.(track.git.tests, :text).strip

    <<~TEXT.strip
      ## #{header}

      #{contents}
    TEXT
  end

  def submitting
    header = I18n.t("exercises.documents.submitting_solution_header").strip
    contents = I18n.t("exercises.documents.submitting_solution",
      solution_file_paths: exercise.git.solution_filepaths.join(" ")).strip

    <<~TEXT.strip
      ## #{header}

      #{contents}
    TEXT
  end

  def help
    header = I18n.t("exercises.documents.help_header").strip
    intro = I18n.t("exercises.documents.help_intro").strip

    general_help = I18n.t('exercises.documents.help_pages', track_title: track.title, track_slug: track.slug)
    submit_incomplete = I18n.t('exercises.documents.help_submit_incomplete')
    track_help = Markdown::Render.(track.git.help, :text).strip

    <<~TEXT.strip
      ## #{header}

      #{intro}

      #{general_help}

      #{submit_incomplete}

      #{track_help}
    TEXT
  end
end
