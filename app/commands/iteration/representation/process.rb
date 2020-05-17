class Iteration
  class Representation
    class Process
      include Mandate

      def initialize(iteration_uuid, ops_status, ops_message, representation)
        @iteration = Iteration.find_by_uuid!(iteration_uuid)
        @ops_status = ops_status.to_i
        @ops_message = ops_message
        @representation = representation
      end


    end
  end
end
