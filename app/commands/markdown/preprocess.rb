class Markdown::Preprocess
  include Mandate

  initialize_with :text

  def call
    text.gsub(/^`{3,}(.*?)`{3,}\s*$/m) { "\n#{Regexp.last_match(0)}\n" }
  end
end
