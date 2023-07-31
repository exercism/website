class Exercise::Contributorship::Create
  include Mandate

  initialize_with :exercise, :contributor

  def call
    begin
      contributorship = exercise.contributorships.create!(contributor:)
    rescue ActiveRecord::RecordNotUnique
      return nil
    end

    User::ReputationToken::Create.defer(
      contributor,
      :exercise_contribution,
      contributorship:
    )
  end
end
