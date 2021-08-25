module Mentor
  class Request
    class Cancel
      include Mandate

      initialize_with :request

      # TODO: Temporary implementation
      def call
        ActiveRecord::Base.transaction do
          request.solution.update!(mentoring_status: :none)
          request.destroy
        end
      end
    end
  end
end
