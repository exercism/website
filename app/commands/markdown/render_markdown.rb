class Markdown::RenderMarkdown
  include Mandate

  def initialize(text, strip_h1: true)
    @text = text
    @strip_h1 = strip_h1
  end

  def call
    doc = Markdown::RenderDoc.(text)
    preprocessed_doc = Markdown::Preprocess.(doc, strip_h1: strip_h1)
    preprocessed_doc.to_commonmark(:DEFAULT, 0)
  end

  private
  attr_reader :text, :strip_h1
end
