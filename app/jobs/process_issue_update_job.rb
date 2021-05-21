class ProcessIssueUpdateJob < ApplicationJob
  queue_as :default

  def perform(issue)
    if issue[:action] == 'deleted'
      Github::Issue::Destroy.(issue[:node_id])
    else
      Github::Issue::CreateOrUpdate.(
        issue[:node_id],
        number: issue[:number],
        title: issue[:title],
        state: issue[:state],
        repo: issue[:repo],
        labels: issue[:labels],
        opened_at: issue[:opened_at],
        opened_by_username: issue[:opened_by_username]
      )
    end
  end
end
