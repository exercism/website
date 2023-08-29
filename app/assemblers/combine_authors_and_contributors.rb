class CombineAuthorsAndContributors
  include Mandate

  initialize_with :authors, :contributors, limit: 3, user_id_column: :id

  def call
    users = randomize(authors, limit)

    updated_limit = limit - users.count
    users += randomize(contributors, updated_limit) if updated_limit.positive?

    users
  end

  private
  def randomize(users, num_users)
    if users.is_a?(ActiveRecord::Relation)
      ids = users.distinct.pluck(user_id_column)
      ids.shuffle.slice!(3, ids.size)
      User.includes(:profile).where(id: ids).limit(num_users).to_a
    else
      users.shuffle.take(num_users)
    end
  end
end
