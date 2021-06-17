class ContributorTeam::Membership
  class CreateOrUpdate
    include Mandate

    initialize_with :user, :team, :attributes

    def call
      membership = ContributorTeam::Membership.create_or_find_by!(user: user, team: team) do |m|
        m.attributes = attributes
      end

      membership.update!(attributes)
      membership
    end
  end
end
