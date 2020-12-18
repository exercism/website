module ReactComponents
  module Common
    class MarkdownEditor < ReactComponent
      initialize_with :uuid

      def to_s
        super("common-markdown-editor", { uuid: uuid })
      end
    end
  end
end
