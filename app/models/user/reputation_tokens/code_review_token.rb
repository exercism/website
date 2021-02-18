class User::ReputationTokens::CodeReviewToken < User::ReputationToken
  params :repo, :pr_id
  category :building
  reason :reviewed_code
  value 3

  def guard_params
    "PR##{repo}/#{pr_id}"
  end

  def i18n_params
    {
      repo: repo,
      pr_id: pr_id
    }
  end
end
