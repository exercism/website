module ReactComponents
  module Test
    class LoadingOverlay < ReactComponent
      def to_s
        super(
          "test-loading-overlay",
          { url: Exercism::Routes.docs_url }
        )
      end
    end
  end
end
