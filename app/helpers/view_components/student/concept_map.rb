module ViewComponents
  module Student
    class ConceptMap < ViewComponent
      initialize_with :data

      def to_s
        react_component(
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
