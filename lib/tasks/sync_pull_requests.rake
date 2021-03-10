desc 'Sync pull requests'
task sync_pull_requests: :environment do
  Git::PullRequests::SyncRepos.call
end
