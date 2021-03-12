desc 'Sync pull requests reputation'
task sync_pull_requests_reputation: :environment do
  Github::PullRequests::SyncRepos.()
  User::ReputationToken::AwardForPullRequests.()
end
