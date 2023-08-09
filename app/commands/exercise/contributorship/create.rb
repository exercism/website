class Exercise::Contributorship::Create
  include Mandate

  initialize_with :exercise, :contributor

  def call
    exercise.contributorships.find_or_create_by(contributor:).tap do |contributorship|
      User::ReputationToken::Create.defer(
        contributor,
        :exercise_contribution,
        contributorship:
      )
    end
  end
end
