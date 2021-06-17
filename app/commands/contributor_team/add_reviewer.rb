class ContributorTeam
  class AddReviewer
    include Mandate

    initialize_with :user, :attributes

    def call
      team = ContributorTeam.find_by!(github_name: "reviewers")
      ContributorTeam::Membership::CreateOrUpdate.(user, team, attributes)
    end
  end
end
