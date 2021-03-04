desc 'Import GitHub pull requests'
task import_github_pull_requests: :environment do
  Git::SyncPullRequests.call
end
