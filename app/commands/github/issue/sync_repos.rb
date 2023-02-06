class Github::Issue::SyncRepos
  include Mandate

  def call
    repos.each do |repo|
      Github::Issue::SyncRepo.(repo)
    rescue StandardError => e
      Rails.logger.error "Error syncing issues for #{repo}: #{e}"
    end
  end

  private
  def repos
    # The GraphQL API could also have been used. That would have led to more
    # efficient retrieval (less data returned), but we decided against it as
    # the code would be far more verbose
    response = Exercism.octokit_client.search_repositories("org:exercism is:public")
    response[:items].map { |item| item[:full_name] }
  end
end
