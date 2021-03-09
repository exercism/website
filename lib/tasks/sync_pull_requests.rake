desc 'Sync pull requests'
task sync_pull_requests: :environment do
  Git::SyncPullRequests.call
end
