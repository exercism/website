module Mentor
  class Request
    class Cancel
      include Mandate

      initialize_with :request

      def call
        request.cancelled!
      end
    end
  end
end
