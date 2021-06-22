class ContributorTeam
  class Create
    include Mandate

    initialize_with :name, :attributes

    def call
      ContributorTeam.create!(name: name, **attributes).tap do |team|
        Github::Team::Create.(team.github_name, team.track.slug, parent_team: track_maintainers_team) if team.track.present?
      end
    rescue ActiveRecord::RecordNotUnique
      ContributorTeam.find_by!(name: name).tap do |team|
        team.update!(attributes)
      end
    end

    private
    def track_maintainers_team
      Github::Team.new('track-maintainers')
    end
  end
end
