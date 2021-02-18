class Markdown::Render
  include Mandate

  def initialize(text, strip_h1: true, lower_heading_levels_by: 0)
    @text = text
    @strip_h1 = strip_h1
    @lower_heading_levels_by = lower_heading_levels_by
  end

  def call
    doc = Markdown::ParseDoc.(text)
    preprocessed = Markdown::Preprocess.(doc, text, strip_h1: strip_h1, lower_heading_levels_by: lower_heading_levels_by)
    preprocessed[:text]
  end

  private
  attr_reader :text, :strip_h1, :lower_heading_levels_by
end
