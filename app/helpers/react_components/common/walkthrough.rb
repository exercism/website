module ReactComponents
  module Common
    class Walkthrough < ReactComponent
      initialize_with :user

      def to_s
        super("common-walkthrough", AssembleWalkthrough.(user))
      end
    end
  end
end
