class Github::Task::SyncTasks
  include Mandate

  def call
    issues.each do |issue|
      Github::Task::SyncTask.(issue)
    rescue StandardError => e
      Rails.logger.error "Error syncing task for issue #{issue.repo}/#{issue.number}: #{e}"
    end
  end

  private
  def issues
    Github::Issue.includes(:labels)
  end
end
