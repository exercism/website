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

      heading = parse_title(header).downcase
      hints[heading] = list.each.map { |list_item| list_item.each.first.to_html }
    end
  end

  def tasks
    instructions_doc.each.
      drop_while { |node| node.type != :header }.
      chunk_while { |_, nxt| nxt.type != :header }.
      each_with_object([]) do |nodes, tasks|
        task_title = parse_title(nodes.first)
        task_text = nodes.drop(1).each.map(&:to_html).join.strip
        task_hints = hints[task_title.downcase].to_a

        tasks << { title: task_title, text: task_text, hints: task_hints }
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

  def parse_title(header)
    header.to_plaintext.strip.gsub(/^(^\d+)\.\s*(.*)/, '\2')
  end

  def parse_markdown_doc(filepath)
    CommonMarker.render_doc(
      filepath,
      :DEFAULT,
      %i[table tagfilter strikethrough]
    )
  end
end
