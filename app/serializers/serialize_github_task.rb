class SerializeGithubTask
  include Mandate

  initialize_with :task

  def call
    {
      title: task.title,
      track: task.track.present? ? {
        slug: task.track.slug,
        title: task.track.title,
        icon_url: task.track.icon_url
      } : nil,
      opened_by_username: task.opened_by_username,
      opened_at: task.opened_at.iso8601,
      is_new: task.opened_at > 1.week.ago,
      links: {
        github_url: task.issue_url
      }
    }
  end
end
