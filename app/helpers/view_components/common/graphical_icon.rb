module ViewComponents
  module Common
    class GraphicalIcon < ViewComponent
      initialize_with :icon

      def to_s
        react_component("common-graphical-icon", { icon: icon })
      end
    end
  end
end
