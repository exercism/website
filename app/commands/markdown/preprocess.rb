class Markdown::Preprocess
  include Mandate

  def initialize(text, remove_level_one_headings: false)
    @text = text.to_s
    @remove_level_one_headings = remove_level_one_headings
  end

  def call
    preprocessed_text = text.gsub(/^`{3,}(.*?)`{3,}\s*$/m) { "\n#{Regexp.last_match(0)}\n" }
    preprocessed_text = preprocessed_text.gsub(/^# .+?$/, '').strip if remove_level_one_headings
    preprocessed_text
  end

  private
  attr_reader :text, :remove_level_one_headings
end
