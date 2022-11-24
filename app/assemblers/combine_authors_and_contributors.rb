class CombineAuthorsAndContributors
  include Mandate

  initialize_with :authors, :contributors, limit: 3

  def call
    users = randomize(authors, limit)
    users += randomize(contributors, limit - users.count)
    users
  end

  private
  def randomize(users, num_users)
    if users.is_a?(ActiveRecord::Relation)
      ids = users.pluck(:id).shuffle.take(num_users)
      users.includes(:profile).where(id: ids).to_a
    else
      users.shuffle.take(num_users)
    end
  end
end
