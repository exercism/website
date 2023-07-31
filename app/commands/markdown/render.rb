class Markdown::Render
  include Mandate

  def initialize(text, output_type, strip_h1: true, lower_heading_levels_by: 0)
    raise "Invalid output type" unless OUTPUT_TYPES.include?(output_type)

    @text = text
    @output_type = output_type
    @strip_h1 = strip_h1
    @lower_heading_levels_by = lower_heading_levels_by
  end

  def call
    doc = Markdown::ParseDoc.(text)
    preprocessed = Markdown::Preprocess.(doc, text, strip_h1:, lower_heading_levels_by:)

    case output_type
    when :doc
      preprocessed[:doc]
    when :text
      preprocessed[:text]
    end
  end

  private
  attr_reader :text, :output_type, :strip_h1, :lower_heading_levels_by

  OUTPUT_TYPES = %i[doc text].freeze
  private_constant :OUTPUT_TYPES
end
