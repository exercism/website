module ReactComponents
  module Contributing
    class Task < ReactComponent
      initialize_with :task

      def to_s
        super("contributing-task", { task: task })
      end
    end
  end
end
