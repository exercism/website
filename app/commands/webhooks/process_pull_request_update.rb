module Webhooks
  class ProcessPullRequestUpdate
    include Mandate

    initialize_with :pull_request_update

    def call = ProcessPullRequestUpdateJob.perform_later(pull_request_update)
  end
end
