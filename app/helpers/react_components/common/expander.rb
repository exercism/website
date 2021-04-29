module ReactComponents
  module Common
    class Expander < ReactComponent
      def initialize(content, button_text, class_name: nil)
        super()

        @content = content
        @button_text = button_text
        @class_name = class_name
      end

      def to_s
        super("common-expander", {
          content: content,
          button_text: button_text,
          class_name: class_name
        })
      end

      private
      attr_reader :content, :button_text, :class_name
    end
  end
end
