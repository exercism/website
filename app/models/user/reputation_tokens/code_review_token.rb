class User::ReputationTokens::CodeReviewToken < User::ReputationToken
  params :repo, :pr_node_id, :pr_number
  category :building
  reason :reviewed_code
  value 3

  def guard_params
    "PR##{pr_node_id}"
  end

  def i18n_params
    {
      repo: repo,
      pr_number: pr_number
    }
  end
end
