class Markdown::Preprocess
  include Mandate

  def initialize(doc, text, strip_h1: true)
    @doc = doc
    @text = text
    @strip_h1 = strip_h1
    @mutations = []
  end

  def call
    strip_h1_headings! if strip_h1
    apply_mutations! if mutations.present?

    { doc: doc, text: text }
  end

  private
  attr_reader :doc, :text, :strip_h1, :lines, :mutations

  def strip_h1_headings!
    doc.each do |node|
      mutations << { type: :delete, node: node } if node.type == :header && node.header_level == 1
    end
  end

  def apply_mutations!
    @lines = text.lines(chomp: true)

    mutations_in_reverse_line_order.each do |mutation|
      case mutation[:type]
      when :delete
        lines.delete_at(mutation[:node].sourcepos[:start_line] - 1)
        mutation[:node].delete
      end
    end

    @text = lines.join("\n")
  end

  def mutations_in_reverse_line_order
    mutations.sort_by { |mutation| -mutation[:node].sourcepos[:start_line] }
  end
end
