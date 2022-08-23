class ProcessIssueUpdateJob < ApplicationJob
  queue_as :default

  def perform(issue_data)
    if issue_data[:action] == 'deleted'
      Github::Issue::Destroy.(issue_data[:node_id])
      Github::Task::Destroy.(issue_data[:html_url])
      return
    end

    issue = Github::Issue::CreateOrUpdate.(
      issue_data[:node_id],
      number: issue_data[:number],
      title: issue_data[:title],
      state: issue_data[:state],
      repo: issue_data[:repo],
      labels: issue_data[:labels],
      opened_at: issue_data[:opened_at],
      opened_by_username: issue_data[:opened_by_username]
    )
    Github::Task::SyncTask.(issue)
    User::ReputationToken::AwardForIssue.(**issue_data)
  end
end
