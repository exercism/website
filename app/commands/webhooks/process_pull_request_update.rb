class Webhooks::ProcessPullRequestUpdate
  include Mandate

  initialize_with pull_request_update: Mandate::KWARGS

  def call = ProcessPullRequestUpdateJob.perform_later(pull_request_update)
end
