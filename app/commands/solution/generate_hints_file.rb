class Solution
  class GenerateHintsFile
    include Mandate

    initialize_with :solution

    def call
      hints_text = Markdown::Render.(solution.git_exercise.hints, :text).strip

      <<~TEXT.strip
        # Hints

        #{hints_text}
      TEXT
    end
  end
end
