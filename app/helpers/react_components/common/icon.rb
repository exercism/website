module ReactComponents
  module Common
    class Icon < ReactComponent
      initialize_with :icon, :alt

      def to_s
        super("common-icon", { icon:, alt: })
      end
    end
  end
end
