module ReactComponents
  module Common
    class Expander < ReactComponent
      initialize_with :content, :button_text
      def to_s
        super("common-expander", {
          content: content,
          button_text: button_text
        })
      end
    end
  end
end
