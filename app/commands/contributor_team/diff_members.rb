class ContributorTeam
  class DiffMembers
    include Mandate

    initialize_with :team

    def call
      db_member_usernames = team.members.pluck(:github_username).to_set
      github_member_username = team.github_team.members.pluck(:login).to_set

      {
        in_both: db_member_usernames & github_member_username,
        only_in_db: db_member_usernames - github_member_username,
        only_on_github: github_member_username - db_member_usernames
      }
    end
  end
end
