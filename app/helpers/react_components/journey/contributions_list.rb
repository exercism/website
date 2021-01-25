module ReactComponents
  module Journey
    class ContributionsList < ReactComponent
      def to_s
        super(
          "journey-contributions-list", {
            endpoint: Exercism::Routes.api_reputation_index_url
          })
      end
    end
  end
end
