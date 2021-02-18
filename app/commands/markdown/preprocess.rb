class Markdown::Preprocess
  include Mandate

  def initialize(doc, text, strip_h1: true)
    @doc = doc
    @text = text
    @strip_h1 = strip_h1
    @deletions = []
    @updates = []
  end

  def call
    strip_h1_headings! if strip_h1
    apply_mutations_to_text!

    { doc: doc, text: text }
  end

  private
  attr_reader :doc, :text, :strip_h1, :lines, :deletions, :updates

  def strip_h1_headings!
    doc.each do |node|
      next unless node.type == :header && node.header_level == 1

      node.delete
      deletions << node
    end
  end

  def apply_mutations_to_text!
    return if deletions.empty? && updates.empty?

    @lines = text.lines(chomp: true)

    apply_deletions_to_text!

    @text = lines.join("\n")
  end

  def apply_deletions_to_text!
    deletions.reverse_each { |deletion| lines.delete_at(deletion.sourcepos[:start_line] - 1) }
  end
end
