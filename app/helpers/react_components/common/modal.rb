module ReactComponents
  module Common
    class Modal < ReactComponent
      initialize_with :html

      def to_s
        super("common-modal", html: html)
      end
    end
  end
end
