module ReactComponents
  module Common
    class WalkthroughButton < ReactComponent
      initialize_with :user

      def to_s
        super("common-walkthrough-button", AssembleWalkthrough.(user))
      end
    end
  end
end
