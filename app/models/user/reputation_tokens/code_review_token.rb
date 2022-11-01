class User::ReputationTokens::CodeReviewToken < User::ReputationToken
  params :repo, :pr_node_id, :pr_number, :pr_title, :merged_at, :closed_at
  category :maintaining
  reason :reviewed_code
  levels %i[tiny small medium large massive]
  values({ tiny: 1, small: 2, medium: 5, large: 10, massive: 20 })

  before_validation on: :create do
    self.earned_on = self.merged_at || self.closed_at || Time.current unless earned_on

    unless track
      normalized_repo = repo.gsub(/-(test-runner|analyzer|representer)$/, '')
      self.track_id = Track.where(repo_url: "https://github.com/#{normalized_repo}").pick(:id)
    end
  end

  def guard_params = "PR##{pr_node_id}"

  def i18n_params
    {
      repo: repo.split("/").last,
      pr_number:,
      pr_title:
    }
  end

  def icon_name = "pull-request-review"
end
