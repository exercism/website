class SerializeContributors
  include Mandate

  def initialize(users, starting_rank)
    @users = users
    @starting_rank = starting_rank
  end

  def call
    users.map.with_index do |user, idx|
      SerializeContributor.(user, starting_rank + idx)
    end
  end

  private
  attr_reader :users, :starting_rank
end
