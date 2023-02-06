class Exercise::Approach::Introduction::Contributorship::Create
  include Mandate

  initialize_with :exercise, :contributor

  def call
    exercise.approach_introduction_contributorships.find_create_or_find_by!(contributor:).tap do |contributorship|
      User::ReputationToken::Create.defer(contributor, :exercise_approach_introduction_contribution, contributorship:)
    end
  end
end
