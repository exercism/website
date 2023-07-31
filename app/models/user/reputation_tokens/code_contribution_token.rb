class User::ReputationTokens::CodeContributionToken < User::ReputationToken
  params :repo, :pr_node_id, :pr_number, :pr_title, :merged_at
  category :building
  reason :contributed_code
  levels %i[tiny small medium large massive]
  values({ tiny: 3, small: 5, medium: 12, large: 30, massive: 100 })

  before_validation on: :create do
    self.earned_on = self.merged_at || Time.current unless earned_on

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

  def icon_name = "pull-request-open"
end
