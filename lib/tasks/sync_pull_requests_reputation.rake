desc 'Sync pull requests reputation'
task sync_pull_requests_reputation: :environment do
  Git::SyncPullRequestsReputation.call
end
