class SerializeExerciseAssignment
  include Mandate

  initialize_with :solution

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
    return Markdown::Parse.(instructions) if solution.exercise.practice_exercise?

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
    hints[0].to_a
  end

  memoize
  def hints
    # Hints documents are structured as a series of headers and lists:
    # e.g.
    #  ## Header
    #  - foo
    #  - bar

    hints_doc.
      each.
      slice_before { |x| x.type == :header && x.header_level == 2 }.
      each_with_object({}) do |chunk, hints|
        task_id = parse_task_id(chunk.each.first)
        hints[task_id] = chunk.each.drop(1).map { |content| Markdown::Parse.(content.to_commonmark) }
      end
  end

  def tasks
    # Practice exercises don't have any tasks
    return [] if solution.exercise.practice_exercise?

    instructions_doc.each.
      # Skip the overview part of the instructions
      drop_while { |node| node.type != :header }.
      # Convert to chunks that start with a header node and subsequent
      # sibling nodes up until the next header
      chunk_while { |_, nxt| nxt.type != :header }.
      map.with_index do |nodes, i|
        task_id = parse_task_id(nodes.first)
        task_title = parse_task_title(nodes.first)
        task_text = Markdown::Parse.(nodes[1..].each.map(&:to_commonmark).join("\n"))
        task_hints = hints[task_id].to_a

        { id: i + 1, title: task_title, text: task_text, hints: task_hints }
      end
  end

  def instructions
    Markdown::Render.(solution.instructions, :text)
  end

  memoize
  def instructions_doc
    Markdown::Render.(instructions, :doc)
  end

  memoize
  def hints_doc
    hints = <<~HINTS.strip
      # Hints

      ## General

      - Hint one
        - Sub hint one
        - Sub hint two
      - Hint two
      - Hint three
        - Sub hint three

      These are more hints

      ~~~exercism/note
      This is a note
      ~~~

      ## 1. Task one

      - Task hint one
        - Task sub hint one

      ## 2. Task two

      - Task hint two
    HINTS

    Markdown::Render.(hints, :doc)
  end

  def parse_task_title(header)
    # Parse the task's title, which is everything after the task number
    # "## 2. Do stuff" becomes "Do stuff"
    # "## General" becomes "General"
    header.to_plaintext.strip.gsub(/^(^\d+)\.\s*(.*)/, '\2')
  end

  def parse_task_id(header)
    # Parse the task's ID, which is the starting number.
    # "## 2. Do stuff" becomes 2
    # "## General" becomes 0
    header.to_plaintext.strip.gsub(/^(^\d+)\.\s*(.*)/, '\1').to_i
  end
end
