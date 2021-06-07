module ReactComponents
  module Common
    class CLIWalkthroughButton < ReactComponent
      initialize_with :user

      def to_s
        super("common-cli-walkthrough-button", AssembleCLIWalkthrough.(user))
      end
    end
  end
end
