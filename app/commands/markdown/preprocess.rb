class Markdown::Preprocess
  include Mandate

  def initialize(doc, text, strip_h1: true, lower_heading_levels_by: 0)
    @doc = doc
    @text = text
    @strip_h1 = strip_h1
    @lower_heading_levels_by = lower_heading_levels_by
    @mutations = []
  end

  def call
    strip_h1_headings! if strip_h1
    lower_heading_levels! if lower_heading_levels_by.positive?
    apply_mutations! if mutations.present?

    { doc: doc, text: text }
  end

  private
  attr_reader :doc, :text, :strip_h1, :lower_heading_levels_by, :lines, :mutations

  def strip_h1_headings!
    doc.each do |node|
      next unless node.type == :header && node.header_level == 1

      mutations << { type: :delete_header, node: node }
    end
  end

  def lower_heading_levels!
    doc.each do |node|
      next unless node.type == :header && (node.header_level > 1 || !strip_h1)

      mutations << { type: :lower_header_level, node: node }
    end
  end

  def apply_mutations!
    @lines = text.lines(chomp: true)

    # As we'll possibly be deleting lines too, we have to process the
    # mutations in reverse order
    mutations_in_reverse_line_order.each do |mutation|
      case mutation[:type]
      when :delete_header
        lines.delete_at(mutation[:node].sourcepos[:start_line] - 1)
        mutation[:node].delete
      when :lower_header_level
        lines[mutation[:node].sourcepos[:start_line] - 1].insert(mutation[:node].sourcepos[:start_column] - 1, '#')
        mutation[:node].header_level = mutation[:node].header_level + lower_heading_levels_by
      end
    end

    @text = lines.join("\n")
  end

  def mutations_in_reverse_line_order
    mutations.sort_by { |mutation| mutation[:node].sourcepos[:start_line] }.reverse
  end
end
