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
    if users.is_a?(ActiveRecord::Relation)
      ids = users.pluck(:id).shuffle.take(limit)
      users.where(id: ids).to_a
    else
      users.shuffle.take(limit)
    end
  end
end
