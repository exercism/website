class Markdown::Preprocess
  include Mandate

  def initialize(text, strip_h1: true) # rubocop:disable Naming/VariableNumber
    @text = text.to_s
    @strip_h1 = strip_h1 # rubocop:disable Naming/VariableNumber
  end

  def call
    preprocessed_text = text.gsub(/^`{3,}(.*?)`{3,}\s*$/m) { "\n#{Regexp.last_match(0)}\n" }
    preprocessed_text = preprocessed_text.gsub(/^# .+?$/, '') if strip_h1 # rubocop:disable Naming/VariableNumber
    preprocessed_text
  end

  private
  attr_reader :text, :strip_h1 # rubocop:disable Naming/VariableNumber
end
