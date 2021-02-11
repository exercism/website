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

      "# #{solution.exercise.title}

Welcome to #{solution.exercise.title} on Exercism's #{solution.track.title} Track.
If you need help running the tests or submitting your code, check out `HELP.md`.
#{hints_text}".strip
    end

    def introduction
      return unless solution.git_exercise.introduction

      introduction_text = Markdown::Preprocess.(solution.git_exercise.introduction, remove_level_one_headings: true)
      introduction_append_text = Markdown::Preprocess.(solution.git_exercise.introduction_append,
        remove_level_one_headings: true)

      "## Introduction\n\n#{introduction_text}\n#{introduction_append_text}".strip
    end

    def instructions
      instructions_text = Markdown::Preprocess.(solution.git_exercise.instructions, remove_level_one_headings: true)
      instructions_append_text = Markdown::Preprocess.(solution.git_exercise.instructions_append,
        remove_level_one_headings: true)

      "## Instructions\n\n#{instructions_text}\n#{instructions_append_text}".strip
    end

    def source
      sources = [created_by, contributed_by, based_on].compact_blank
      return if sources.empty?

      "## Source\n\n#{sources.join("\n\n")}".strip
    end

    def created_by
      return if solution.git_exercise.authors.blank?

      text = "### Created by\n"

      solution.git_exercise.authors.each do |author|
        if author[:exercism_username].blank?
          text << "\n- @#{author[:github_username]}"
        else
          text << "\n- #{author[:exercism_username]} (@#{author[:github_username]})"
        end
      end

      text
    end

    def contributed_by
      return if solution.git_exercise.contributors.blank?

      text = "### Contributed to by\n"

      solution.git_exercise.contributors.each do |contributor|
        if contributor[:exercism_username].blank?
          text << "\n- @#{contributor[:github_username]}"
        else
          text << "\n- #{contributor[:exercism_username]} (@#{contributor[:github_username]})"
        end
      end

      text
    end

    def based_on
      return if solution.git_exercise.source.blank? && solution.git_exercise.source_url.blank?

      source = [solution.git_exercise.source, solution.git_exercise.source_url].compact_blank.join(' - ')
      "### Based on\n\n#{source}"
    end
  end
end
