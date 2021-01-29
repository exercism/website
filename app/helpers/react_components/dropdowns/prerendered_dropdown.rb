module ReactComponents
  module Dropdowns
    class PrerenderedDropdown < ReactComponent
      def initialize(menu_button_html:, menu_items_html:)
        super

        @menu_button_html = menu_button_html
        @menu_items_html = menu_items_html
      end

      def to_s
        super("dropdowns-prerendered-dropdown", { menu_button_html: menu_button_html, menu_items_html: menu_items_html })
      end

      private
      attr_reader :menu_button_html, :menu_items_html
    end
  end
end
