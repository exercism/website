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
    convert_inline_links!
    strip_h1_headings! if strip_h1
    lower_heading_levels! if lower_heading_levels_by.positive?
    apply_mutations! if mutations.present?

    { doc:, text: }
  end

  private
  attr_reader :doc, :text, :strip_h1, :lower_heading_levels_by, :lines, :mutations

  def strip_h1_headings!
    doc.each do |node|
      next unless node.type == :header && node.header_level == 1

      mutations << { type: :delete_header, node: }
    end
  end

  def lower_heading_levels!
    doc.each do |node|
      next unless node.type == :header && (node.header_level > 1 || !strip_h1)

      mutations << { type: :lower_header_level, node: }
    end
  end

  def convert_inline_links!
    doc.walk do |node|
      next unless node.type == :link

      link_text = node.each.map(&:to_commonmark).join.strip
      link_text.match(%r{^(concept|exercise):([\w-]+)/([\w-]+)$}) do |m|
        node.url = "https://exercism.org/tracks/#{m[2]}/#{m[1].pluralize}/#{m[3]}"
        node.each.first.string_content = m[3]
      end

      link_text.match(%r{^(article|approach):([\w-]+)/([\w-]+)/([\w-]+)$}) do |m|
        node.url = "https://exercism.org/tracks/#{m[2]}/exercises/#{m[3]}/#{m[1].pluralize}/#{m[4]}"
        node.each.first.string_content = m[4]
      end

      link_text.match(%r{^video:vimeo/(\d+\?h=[0-9a-z]+)$}) do |m|
        node.url = "https://player.vimeo.com/video/#{m[1]}"
      end

      link_text.match(%r{^video:vimeo/(\d+)$}) do |m|
        node.url = "https://player.vimeo.com/video/#{m[1]}"
      end

      link_text.gsub('\\_', '_').match(%r{^video:youtube-mail/([\w_-]+)$}) do |m|
        node.each.first.string_content = node.url
        node.url = "https://www.youtube.com/watch?v=#{m[1]}"
      end
    end
  end

  def apply_mutations!
    @lines = text.lines(chomp: true)

    # As we'll possibly be deleting lines too, we have to process the
    # mutations in reverse order
    mutations_in_reverse_line_order.each do |mutation|
      case mutation[:type]
      when :delete_header
        line_idx = mutation[:node].sourcepos[:start_line] - 1
        lines.delete_at(line_idx)
        lines.delete_at(line_idx) if line_idx < lines.length && lines[line_idx].blank?
        mutation[:node].delete
      when :lower_header_level
        lines[mutation[:node].sourcepos[:start_line] - 1].insert(mutation[:node].sourcepos[:start_column] - 1, '#')

        new_level = mutation[:node].header_level + lower_heading_levels_by
        mutation[:node].header_level = [new_level, 6].min
      end
    end

    @text = lines.join("\n")
  end

  def mutations_in_reverse_line_order
    mutations.sort_by { |mutation| mutation[:node].sourcepos[:start_line] }.reverse
  end
end
