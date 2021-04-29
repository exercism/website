desc 'Sync pull requests reputation'
task sync_pull_requests_reputation: :environment do
  Github::PullRequest::SyncRepos.()
  Github::OrganizationMember::SyncMembers.()
  User::ReputationToken::AwardForPullRequests.()
end
