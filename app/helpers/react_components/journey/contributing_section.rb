module ReactComponents
  module Journey
    class ContributingSection < ReactComponent
      def to_s
        super("journey-contributing-section", AssembleContributionsSummary.(current_user))
      end
    end
  end
end
