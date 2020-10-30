module ViewComponents
  module Common
    class CopyToClipboardButton < ViewComponent
      initialize_with :text_to_copy

      def to_s
        react_component("common-copy-to-clipboard-button", { text_to_copy: text_to_copy })
      end
    end
  end
end
