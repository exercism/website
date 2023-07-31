class Solution::GenerateReadmeFile
  include Mandate

  initialize_with :solution

  def call
    [
      preamble,
      introduction,
      instructions,
      source
    ].compact_blank.join("\n\n")
  end

  private
  def preamble
    hints_text = I18n.t("exercises.documents.hints_reference").strip if solution.hints.present?

    welcome_text = I18n.t("exercises.documents.welcome", exercise_title: solution.exercise.title,
      track_title: solution.track.title).strip
    help_text = I18n.t("exercises.documents.help_reference").strip

    <<~TEXT.strip
      # #{solution.exercise.title}

      #{welcome_text}
      #{help_text}
      #{hints_text}
    TEXT
  end

  def introduction
    return if solution.introduction.blank?

    <<~TEXT.strip
      ## Introduction

      #{Markdown::Render.(solution.introduction, :text)}
    TEXT
  end

  def instructions
    <<~TEXT.strip
      ## Instructions

      #{Markdown::Render.(solution.instructions, :text)}
    TEXT
  end

  def source
    sources_text = [created_by, contributed_by, based_on].compact_blank.join("\n\n")
    return if sources_text.empty?

    <<~TEXT.strip
      ## Source

      #{sources_text}
    TEXT
  end

  def created_by
    return if solution.git_exercise.authors.blank?

    authors_text = users_list(solution.git_exercise.authors)

    <<~TEXT.strip
      ### Created by

      #{authors_text}
    TEXT
  end

  def contributed_by
    return if solution.git_exercise.contributors.blank?

    contributors_text = users_list(solution.git_exercise.contributors)

    <<~TEXT.strip
      ### Contributed to by

      #{contributors_text}
    TEXT
  end

  def users_list(users)
    users.map { |user| "- @#{user}" }.join("\n")
  end

  def based_on
    return unless solution.git_exercise.source.present? || solution.git_exercise.source_url.present?

    source_text = [solution.git_exercise.source, solution.git_exercise.source_url].compact_blank.join(' - ')

    <<~TEXT.strip
      ### Based on

      #{source_text}
    TEXT
  end
end
