class Exercise::Contributorship::Create
  include Mandate

  initialize_with :exercise, :contributor

  def call
    exercise.contributorships.find_create_or_find_by!(contributor:).tap do |contributorship|
      User::ReputationToken::Create.defer(
        contributor,
        :exercise_contribution,
        contributorship:,
        # This is called in a big transaction, so give it time
        # to materialise to the database before calling things.
        wait: 30.seconds
      )
    end
  end
end
