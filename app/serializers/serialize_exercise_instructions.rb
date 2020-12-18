class SerializeExerciseInstructions
  include Mandate

  initialize_with :exercise

  def call
    {
      overview: overview,
      general_hints: general_hints
    }
  end

  private
  def overview; end

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

  memoize
  def hints_doc
    CommonMarker.render_doc(
      exercise.git.hints,
      :DEFAULT,
      %i[table tagfilter strikethrough]
    )
  end
end
