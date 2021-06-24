class ContributorTeam
  class Create
    include Mandate

    initialize_with :name, :repo_names, :attributes

    def call
      ContributorTeam.create!(name: name, **attributes).tap do |team|
        team.update!(repos: repos(team))
        Github::Team::Create.(team.github_name, repo_names, parent_team: parent_team)
      end
    rescue ActiveRecord::RecordNotUnique
      ContributorTeam.find_by!(name: name).tap do |team|
        team.repos = repos(team)
        team.update!(attributes)
      end
    end

    private
    def parent_team
      return if attributes[:parent_team].blank?
    end

    def repos(team)
      repo_names.to_a.map do |repo_name|
        ContributorTeam::Repo.create_or_find_by!(team: team, github_full_name: repo_name)
      end
    end
  end
end
