class CombineAuthorsAndContributors
  include Mandate

  initialize_with :authors, :contributors, limit: 3

  def call
    users = randomize(authors, limit)
    users += randomize(contributors, limit - users.count)
    users
  end

  private
  def randomize(users, limit)
    return users.random.limit(limit).to_a if users.respond_to?(:random)

    users.shuffle
    users.take(limit)
  end
end
