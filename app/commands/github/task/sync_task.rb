class Github::Task::SyncTask
  include Mandate

  initialize_with :issue

  def call
    return destroy_task! if closed? || claimed?
    return destroy_task! unless labeled?

    create_or_update_task!
  end

  private
  def closed?
    issue.status == :closed
  end

  def claimed?
    labels.any? { |label| label.name == Github::IssueLabel.for_type(:status, :claimed) }
  end

  def labeled?
    types = %i[action knowledge module size type]

    labels.any? do |label|
      types.any? do |type|
        label.of_type?(type)
      end
    end
  end

  def create_or_update_task!
    Github::Task::CreateOrUpdate.(
      issue.github_url,
      repo: issue.repo,
      title: issue.title,
      opened_at: issue.opened_at,
      opened_by_username: issue.opened_by_username,
      action: find_label_of_type(:action),
      knowledge: find_label_of_type(:knowledge),
      area: find_label_of_type(:module),
      size: find_label_of_type(:size),
      type: find_label_of_type(:type)
    )
  end

  def destroy_task!
    Github::Task::Destroy.(issue.github_url)
  end

  def find_label_of_type(type)
    labels.find { |l| l.of_type?(type) }&.value
  end

  memoize
  def labels
    issue.labels.to_a
  end
end
