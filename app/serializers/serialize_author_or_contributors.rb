class SerializeAuthorOrContributors
  include Mandate

  initialize_with :users

  def call
    eager_loaded_users.map { |user| SerializeAuthorOrContributor.(user) }
  end

  private
  def eager_loaded_users
    users.to_active_relation.includes(:profile)
  end
end
