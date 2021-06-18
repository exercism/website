module Github
  class Team
    class Create
      include Mandate

      initialize_with :name, :repo

      def call
        Github::Team.new(name).create(repo)
      end
    end
  end
end
