class User::ReputationTokens::CodeReviewToken < User::ReputationToken
  params :repo, :pr_node_id, :pr_number, :pr_title
  category :maintaining
  reason :reviewed_code
  levels %i[minor regular major]
  values({ minor: 2, regular: 5, major: 10 })

  before_validation on: :create do
    self.track_id = Track.where(repo_url: "https://github.com/#{repo}").pick(:id) unless track
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
    "pull-request-review"
  end
end
