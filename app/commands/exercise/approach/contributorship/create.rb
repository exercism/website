class Exercise::Approach::Contributorship::Create
  include Mandate

  initialize_with :approach, :contributor

  def call
    approach.contributorships.find_create_or_find_by!(contributor:).tap do |contributorship|
      User::ReputationToken::Create.defer(contributor, :exercise_approach_contribution, contributorship:)
    end
  end
end
