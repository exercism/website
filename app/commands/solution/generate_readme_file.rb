class Solution
  class GenerateReadmeFile
    include Mandate

    initialize_with :solution

    def call
      [preamble, introduction, instructions, source].compact_blank.join("\n\n")
    end

    private
    def preamble
      if solution.git_exercise.hints.present?
        hints_text = "If you get stuck on the exercise, check out `HINTS.md`, but try and solve it without using those first :)" # rubocop:disable Layout/LineLength
      end

      <<~TEXT.strip
        # #{solution.exercise.title}

        Welcome to #{solution.exercise.title} on Exercism's #{solution.track.title} Track.
        If you need help running the tests or submitting your code, check out `HELP.md`.
        #{hints_text}
      TEXT
    end

    def introduction
      return if solution.git_exercise.introduction.blank?

      introduction_text = Markdown::Preprocess.(solution.git_exercise.introduction).strip
      introduction_append_text = Markdown::Preprocess.(solution.git_exercise.introduction_append).strip

      <<~TEXT.strip
        ## Introduction

        #{introduction_text}
        #{introduction_append_text}
      TEXT
    end

    def instructions
      instructions_text = Markdown::Preprocess.(solution.git_exercise.instructions).strip
      instructions_append_text = Markdown::Preprocess.(solution.git_exercise.instructions_append).strip

      <<~TEXT.strip
        ## Instructions

        #{instructions_text}
        #{instructions_append_text}
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
      users.map do |user|
        if user[:exercism_username].blank?
          "- @#{user[:github_username]}"
        else
          "- #{user[:exercism_username]} (@#{user[:github_username]})"
        end
      end.join("\n")
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
end
