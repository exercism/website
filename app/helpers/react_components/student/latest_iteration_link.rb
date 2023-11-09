module ReactComponents
  module Student
    class LatestIterationLink < ReactComponent
      initialize_with :solution

      def to_s
        super("student-latest-iteration-link", {
          latest_iteration:
        })
      end

      def latest_iteration = SerializeIterations.(solution.iterations).last
    end
  end
end
