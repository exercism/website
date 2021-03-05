desc 'Import pull requests'
task import_pull_requests: :environment do
  Git::ImportPullRequests.call
end
