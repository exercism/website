class Markdown::Preprocess
  include Mandate

  def initialize(doc, strip_h1: true)
    @doc = doc
    @strip_h1 = strip_h1
  end

  def call
    strip_h1_headings! if strip_h1
    doc
  end

  private
  attr_reader :doc, :strip_h1

  def strip_h1_headings!
    doc.walk do |node|
      node.delete if node.type == :header && node.header_level == 1
    end
  end
end
