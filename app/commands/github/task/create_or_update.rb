class Github::Task::CreateOrUpdate
  include Mandate

  initialize_with :issue_url, attributes: Mandate::KWARGS

  def call
    task = ::Github::Task.create_or_find_by!(issue_url:) do |t|
      t.attributes = attributes
    end

    task.update!(attributes)
    task
  end
end
