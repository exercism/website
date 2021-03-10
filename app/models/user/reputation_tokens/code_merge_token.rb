class User::ReputationTokens::CodeMergeToken < User::ReputationToken
  params :repo, :pr_id, :pr_number
  category :building
  reason :merged_code
  value 2

  def guard_params
    "PR##{pr_id}"
  end

  def i18n_params
    {
      repo: repo,
      pr_number: pr_number
    }
  end
end
