class SerializeExerciseAssignment
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
    # Practice exercises don't have any tasks, so we can just return
    # the entire instructions without doing any parsing
    return instructions if exercise.practice_exercise?

    # Instructions documents are structured as a series of headers and lists:
    # e.g.
    #  General instructions overview
    #
    #  ## 1. Task one
    #  Task one description
    #
    #  ...
    instructions_doc.each.
      take_while { |node| node.type != :header }. # TODO: should we check if this is a certain level of header?
      map { |node| Markdown::Parse.(node.to_commonmark) }.
      join
  end

  def general_hints
    hints["general"].to_a
  end

  memoize
  def hints
    # Hints documents are structured as a series of headers and lists:
    # e.g.
    #  ## Header
    #  - foo
    #  - bar
    hints_doc.each_cons(2).each_with_object({}) do |(header, list), hints|
      # TODO: Add an issue to the relevant track via a async job
      # if any of these are invalid
      next unless header.type == :header
      next unless header.header_level == 2
      next unless list.type == :list

      heading = parse_title(header).downcase
      hints[heading] = list.each.map { |list_item| Markdown::Parse.(list_item.each.first.to_commonmark) }
    end
  end

  def tasks
    # Practice exercises don't have any tasks
    return [] if exercise.practice_exercise?

    instructions_doc.each.
      # Skip the overview part of the instructions
      drop_while { |node| node.type != :header }.
      # Convert to chunks that start with a header node and subsequent
      # sibling nodes up until the next header
      chunk_while { |_, nxt| nxt.type != :header }.
      map do |nodes|
        task_title = parse_title(nodes.first)
        task_text = Markdown::Parse.(nodes[1..].each.map(&:to_commonmark).join)
        task_hints = hints[task_title.downcase].to_a

        { title: task_title, text: task_text, hints: task_hints }
      end
  end

  def instructions
    [
      Markdown::RenderMarkdown.(exercise.git.instructions).strip,
      Markdown::RenderMarkdown.(exercise.git.instructions_append).strip
    ].join("\n\n").strip
  end

  memoize
  def instructions_doc
    Markdown::RenderDoc.(instructions)
  end

  memoize
  def hints_doc
    Markdown::RenderDoc.(exercise.git.hints || '')
  end

  def parse_title(header)
    # Extract everything after the task number
    # "## 2. Do stuff" becomes "Do stuff"
    header.to_plaintext.strip.gsub(/^(^\d+)\.\s*(.*)/, '\2')
  end
end
