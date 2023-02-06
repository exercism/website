class User::ReputationTokens::IssueAuthorToken < User::ReputationToken
  params :repo, :issue_node_id, :issue_number, :issue_title, :opened_at
  category :maintaining
  reason :opened_issue
  levels %i[large massive]
  values({ large: 30, massive: 100 })

  before_validation on: :create do
    self.earned_on = self.opened_at || Time.current unless earned_on

    unless track
      normalized_repo = repo.gsub(/-(test-runner|analyzer|representer)$/, '')
      self.track_id = Track.where(repo_url: "https://github.com/#{normalized_repo}").pick(:id)
    end
  end

  def guard_params = "issue##{issue_node_id}"

  def i18n_params
    {
      repo: repo.split("/").last,
      issue_number:,
      issue_title:
    }
  end
end
