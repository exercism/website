module ReactComponents
  module Student
    class ConceptMap < ReactComponent
      initialize_with :data

      def to_s
        super(
          "concept-map",
          {
            graph: data
          }
        )
      end

      private
      attr_reader :data
    end
  end
end
