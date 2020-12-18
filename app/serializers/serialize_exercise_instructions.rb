class SerializeExerciseInstructions
  include Mandate

  initialize_with :exercise

  def call
    {
      overview: overview,
      general_hints: general_hints,
      tasks: tasks
    }
  end

  private
  def overview
    instructions_doc.each.
      take_while { |node| node.type != :header }.
      map(&:to_html).
      join
  end

  def general_hints
    hints["general"].to_a
  end

  memoize
  def hints
    hints_doc.each_cons(2).each_with_object({}) do |(header, list), hints|
      next unless header.type == :header
      next unless header.header_level == 2
      next unless list.type == :list

      heading = header.to_plaintext.strip.gsub(/^(^\d+)\.(.*)/, '\1').downcase
      heading_hints = list.each.map { |list_item| list_item.each.first.to_html }

      hints[heading] = heading_hints
    end
  end

  def tasks
    instructions_doc.each.
      drop_while { |node| node.type != :header }.
      chunk_while { |_, nxt| nxt.type != :header }.
      each_with_object([]) do |nodes, tasks|
        task = {
          title: nodes.first.to_plaintext.strip.gsub(/^(^\d+)\.\s*(.*)/, '\2'),
          text: nodes.drop(1).each.map(&:to_html).join.strip
        }

        tasks << task
      end
  end

  memoize
  def instructions_doc
    parse_markdown_doc(exercise.git.instructions)
  end

  memoize
  def hints_doc
    parse_markdown_doc(exercise.git.hints)
  end

  def parse_markdown_doc(filepath)
    CommonMarker.render_doc(
      filepath,
      :DEFAULT,
      %i[table tagfilter strikethrough]
    )
  end
end
