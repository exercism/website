class SerializeAuthorOrContributors
  include Mandate

  initialize_with :users

  def call = users.map { |user| SerializeAuthorOrContributor.(user) }
end
