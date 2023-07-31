module ReactComponents
  module Common
    class CopyToClipboardButton < ReactComponent
      initialize_with :text_to_copy

      def to_s
        super("common-copy-to-clipboard-button", { text_to_copy: })
      end
    end
  end
end
