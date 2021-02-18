class Markdown::RenderMarkdown
  include Mandate

  def initialize(text, strip_h1: true)
    @text = text
    @strip_h1 = strip_h1
  end

  def call
    doc = Markdown::RenderDoc.(text)
    preprocessed = Markdown::Preprocess.(doc, text, strip_h1: strip_h1)
    preprocessed[:text]
  end

  private
  attr_reader :text, :strip_h1
end
