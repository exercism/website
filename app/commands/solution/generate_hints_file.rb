class Solution::GenerateHintsFile
  include Mandate

  initialize_with :solution

  def call
    hints_text = Markdown::Render.(solution.hints, :text).strip

    <<~TEXT.strip
      # Hints

      #{hints_text}
    TEXT
  end
end
