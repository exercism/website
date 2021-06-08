class User::ReputationTokens::CodeMergeToken < User::ReputationToken
  params :repo, :pr_node_id, :pr_number, :pr_title, :merged_at
  category :maintaining
  reason :merged_code
  levels %i[janitorial reviewal]
  values({ janitorial: 1, reviewal: 5 })

  before_validation on: :create do
    self.earned_on = self.merged_at unless earned_on

    unless track
      normalized_repo = repo.gsub(/-(test-runner|analyzer|representer)$/, '')
      self.track_id = Track.where(repo_url: "https://github.com/#{normalized_repo}").pick(:id)
    end
  end

  def guard_params
    "PR##{pr_node_id}"
  end

  def i18n_params
    {
      repo: repo.split("/").last,
      pr_number: pr_number,
      pr_title: pr_title
    }
  end

  def icon_name
    "pull-request-merge"
  end
end
