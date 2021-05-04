desc 'Fetch and sync all pull requests reputation'
task fetch_and_sync_all_pull_requests_reputation_job: :environment do
  FetchAndSyncAllPullRequestsReputationJob.perform_now
end
