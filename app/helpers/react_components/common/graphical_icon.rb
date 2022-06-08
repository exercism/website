module ReactComponents
  module Common
    class GraphicalIcon < ReactComponent
      initialize_with :icon

      def to_s
        super("common-graphical-icon", { icon: })
      end
    end
  end
end
