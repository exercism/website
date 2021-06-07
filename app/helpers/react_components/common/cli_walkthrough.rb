module ReactComponents
  module Common
    class CLIWalkthrough < ReactComponent
      initialize_with :user

      def to_s
        super("common-cli-walkthrough", AssembleCLIWalkthrough.(user))
      end
    end
  end
end
