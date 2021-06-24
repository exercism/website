class ContributorTeam
  class Create
    include Mandate

    initialize_with :github_name, :attributes

    def call
      ContributorTeam.create!(github_name: github_name, **attributes)
    rescue ActiveRecord::RecordNotUnique
      ContributorTeam.find_by!(github_name: github_name).tap do |team|
        team.update!(attributes)
      end
    end
  end
end
