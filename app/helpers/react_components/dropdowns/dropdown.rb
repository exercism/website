module ReactComponents
  module Dropdowns
    class Dropdown < ReactComponent
      def initialize(menu_button:, menu_items:)
        super()

        @menu_button = menu_button
        @menu_items = menu_items
      end

      def to_s
        super("dropdowns-dropdown", {
          menu_button:,
          menu_items:
        })
      end

      private
      attr_reader :menu_button, :menu_items
    end
  end
end
