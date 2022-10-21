class CombineAuthorsAndContributors
  include Mandate

  initialize_with :authors, :contributors, limit: 3

  def call
    users = authors.random.limit(limit).to_a
    users += contributors.random.limit(limit - users.count).to_a
    users
  end
end
