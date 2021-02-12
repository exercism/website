class Markdown::Preprocess
  include Mandate

  def initialize(text, strip_h1: true)
    @text = text.to_s
    @strip_h1 = strip_h1
  end

  def call
    preprocessed_text = text.gsub(/^`{3,}(.*?)`{3,}\s*$/m) { "\n#{Regexp.last_match(0)}\n" }
    preprocessed_text = preprocessed_text.gsub(/^# .+?$/, '') if strip_h1
    preprocessed_text
  end

  private
  attr_reader :text, :strip_h1
end
