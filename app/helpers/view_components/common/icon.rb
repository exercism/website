module ViewComponents
  module Common
    class Icon < ViewComponent
      initialize_with :icon, :alt

      def to_s
        react_component("common-icon", { icon: icon, alt: alt })
      end
    end
  end
end
