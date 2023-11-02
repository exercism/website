module ReactComponents
  module MLTrainer
    class Dashboard < ReactComponent
      def to_s
        super("ml-trainer-dashboard", {})
      end
    end
  end
end
