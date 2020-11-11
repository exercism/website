module ReactComponents
  module Common
    class Icon < ReactComponent
      initialize_with :icon, :alt

      def to_s
        super("common-icon", { icon: icon, alt: alt })
      end
    end
  end
end
