module ReactComponents
  module Profile
    class ContributionsSummary < ReactComponent
      initialize_with :user

      def to_s
        super("profile-contributions-summary", AssembleContributionsSummary.(user, user.handle))
      end
    end
  end
end
