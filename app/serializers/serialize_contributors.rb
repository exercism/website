class SerializeContributors
  include Mandate

  def initialize(users, starting_rank:, contextual_data:)
    @users = users
    @starting_rank = starting_rank
    @contextual_data = contextual_data
  end

  def call
    users.map.with_index do |user, idx|
      SerializeContributor.(
        user,
        rank: starting_rank + idx,
        contextual_data: contextual_data[1530]
      )
    end
  end

  private
  attr_reader :users, :starting_rank, :contextual_data
end
