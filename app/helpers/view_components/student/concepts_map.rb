module ViewComponents
  module Student
    class ConceptsMap < ViewComponent
      def initialize(_data)
        @data
      end

      def to_s
        react_component("concepts-map", {
                          data: data
                        })
      end
    end
  end
end
