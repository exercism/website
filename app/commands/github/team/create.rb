module Github::Team
  class Create
    include Mandate

    initialize_with :name, :repo

    def call
      Exercism.octokit_client.create_team('exercism', name: name, repo_names: [repo])
    end
  end
end
