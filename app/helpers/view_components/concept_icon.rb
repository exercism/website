module ViewComponents
  class ConceptIcon < ViewComponent
    SIZES = %i[small medium base large huge].freeze

    def initialize(concept, size, view_context: nil)
      raise "Invalid concept icon size #{size}" unless SIZES.include?(size.to_sym)

      super()

      @concept = concept
      @size = size
      @view_context = view_context
    end

    def to_s
      text = concept.name[0, 2]
      classes = "c-concept-icon c--#{size}"
      tag.div(text, class: classes)
    end

    private
    attr_reader :concept, :size
  end
end
