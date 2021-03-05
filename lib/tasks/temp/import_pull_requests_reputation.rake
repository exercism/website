desc 'Import pull requests reputation'
task import_pull_requests_reputatiom: :environment do
  Git::Temp::ImportPullRequests.call
  Git::SyncPullRequestsReputation.call
end
