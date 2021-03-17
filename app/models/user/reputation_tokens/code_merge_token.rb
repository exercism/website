class User::ReputationTokens::CodeMergeToken < User::ReputationToken
  params :repo, :pr_node_id, :pr_number, :pr_title
  category :building
  reason :merged_code
  value 2

  before_validation on: :create do
    self.track = Track.find_by(repo_url: "https://github.com/#{repo}") unless track
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
end
