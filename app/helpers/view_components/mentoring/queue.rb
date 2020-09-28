module ViewComponents
  module Mentoring
    class Queue < ViewComponent
      initialize_with :request

      def to_s
        react_component(
          "mentoring-queue",
          {
            request: request,
            sort_options: SORT_OPTIONS
          }
        )
      end

      SORT_OPTIONS = [
        { value: "recent", label: "Sort by Most Recent" },
        { value: "exercise", label: "Sort by Exercise" },
        { value: "student", label: "Sort by Student" }
      ].freeze
      private_constant :SORT_OPTIONS
    end
  end
end
