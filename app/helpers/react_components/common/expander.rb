module ReactComponents
  module Common
    class Expander < ReactComponent
      def initialize(content, button_text_compressed:, button_text_expanded:, class_name: nil)
        super()

        @content = content
        @button_text_compressed = button_text_compressed
        @button_text_expanded = button_text_expanded
        @class_name = class_name
      end

      def to_s
        super("common-expander", {
          content: content,
          button_text_compressed: button_text_compressed,
          button_text_expanded: button_text_expanded,
          class_name: class_name
        })
      end

      private
      attr_reader :content, :button_text_compressed, :button_text_expanded, :class_name
    end
  end
end
