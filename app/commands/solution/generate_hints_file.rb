class Solution
  class GenerateHintsFile
    include Mandate

    initialize_with :solution

    def call
      hints_text = Markdown::RenderMarkdown.(solution.git_exercise.hints).strip

      <<~TEXT.strip
        # Hints

        #{hints_text}
      TEXT
    end
  end
end
