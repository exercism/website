module ReactComponents
  module Common
    class MarkdownEditor < ReactComponent
      initialize_with :context_id

      def to_s
        super("common-markdown-editor", { context_id: })
      end
    end
  end
end
