module ViewComponents
  module Mentoring
    class Queue < ViewComponent
      initialize_with :request, :sort_options

      def to_s
        react_component("mentoring-queue", { request: request, sort_options: sort_options })
      end
    end
  end
end
