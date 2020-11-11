module ViewComponents
  class ConceptIcon < ViewComponent
    SIZES = %i[small medium huge].freeze

    initialize_with :concept, :size

    def to_s
      raise "Invalid concept icon size #{size}" unless SIZES.include?(size.to_sym)

      text = concept.name[0, 2]
      classes = "c-concept-icon c--#{size}"
      tag.div(text, class: classes)
    end
  end
end
