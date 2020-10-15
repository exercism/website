module ViewComponents
  module Student
    class Editor < ViewComponent
      def initialize(endpoint)
        @endpoint = endpoint
      end

      def to_s
        react_component("student-editor", { endpoint: endpoint })
      end

      private
      attr_reader :endpoint
    end
  end
end
