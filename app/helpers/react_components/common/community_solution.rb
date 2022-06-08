module ReactComponents
  module Common
    class CommunitySolution < ReactComponent
      initialize_with :solution, context:

      def to_s
        super("common-community-solution", {
          solution: SerializeCommunitySolution.(solution),
          context:
        })
      end
    end
  end
end
