class SerializeGithubIssue
  include Mandate

  initialize_with :issue

  def call
    {
      title: issue.title,
      track: issue.track.present? ? {
        slug: issue.track.slug,
        title: issue.track.title,
        icon_url: issue.track.icon_url
      } : nil,
      is_new: issue.opened_at > 1.week.ago,
      links: {
        github_url: "https://github.com/#{issue.repo}/issues/#{issue.number}"
      }
    }
  end
end
