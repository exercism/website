module ReactComponents
  module Common
    class Expander < ReactComponent
      def initialize(content, button_text_compressed:, button_text_expanded:, class_name: nil, content_is_safe: false)
        super()

        @content = content
        @content_is_safe = content_is_safe
        @button_text_compressed = button_text_compressed
        @button_text_expanded = button_text_expanded
        @class_name = class_name
      end

      def to_s
        super("common-expander", {
          content:,
          content_is_safe:,
          button_text_compressed:,
          button_text_expanded:,
          class_name:
        })
      end

      private
      attr_reader :content, :content_is_safe, :button_text_compressed, :button_text_expanded, :class_name
    end
  end
end
