class OpenIssueForDependencyCycleJob < ApplicationJob
  queue_as :default

  def perform(track)
    Github::Issue::OpenForDependencyCycle.(track)
  end
end
