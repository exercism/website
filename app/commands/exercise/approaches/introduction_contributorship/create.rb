class Exercise::Approaches::IntroductionContributorship::Create
  include Mandate

  initialize_with :exercise, :contributor

  def call
    begin
      contributorship = exercise.approach_introduction_contributorships.create!(contributor:)
    rescue ActiveRecord::RecordNotUnique
      return nil
    end

    User::ReputationToken::Create.defer(
      contributor,
      :exercise_approach_introduction_contribution,
      contributorship:
    )
  end
end
