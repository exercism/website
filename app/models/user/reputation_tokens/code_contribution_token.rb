class User::ReputationTokens::CodeContributionToken < User::ReputationToken
  params :repo, :pr_node_id, :pr_number, :pr_title
  category :building
  reason :contributed_code
  levels %i[minor regular major]
  values({ minor: 5, regular: 12, major: 30 })

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
