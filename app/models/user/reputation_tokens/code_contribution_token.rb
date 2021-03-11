class User::ReputationTokens::CodeContributionToken < User::ReputationToken
  params :repo, :pr_node_id, :pr_number
  category :building
  reason :contributed_code
  levels %i[minor regular major]
  values({ minor: 5, regular: 10, major: 15 })

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
