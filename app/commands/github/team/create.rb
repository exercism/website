module Github
  class Team
    class Create
      include Mandate

      def initialize(name, repo, parent_team: nil)
        @name = name
        @repo = repo
        @parent_team = parent_team
      end

      def call
        Github::Team.new(name).create(repo, parent_team: parent_team)
      end

      private
      attr_reader :name, :repo, :parent_team
    end
  end
end
