class Github::Task::Destroy
  include Mandate

  initialize_with :issue_url

  def call
    Github::Task.where(issue_url:).destroy_all
  end
end
