class SerializeContributors
  include Mandate

  initialize_with :users, starting_rank: Mandate::NO_DEFAULT, contextual_data: Mandate::NO_DEFAULT

  def call
    users.map.with_index do |user, idx|
      SerializeContributor.(
        user,
        rank: starting_rank + idx,
        contextual_data: contextual_data[user.id]
      )
    end
  end
end
