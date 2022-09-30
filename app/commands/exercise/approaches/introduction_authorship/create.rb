class Exercise::Approaches::IntroductionAuthorship::Create
  include Mandate

  initialize_with :exercise, :author

  def call
    begin
      authorship = exercise.approach_introduction_authorships.create!(author:)
    rescue ActiveRecord::RecordNotUnique
      return nil
    end

    User::ReputationToken::Create.defer(
      author,
      :exercise_approach_introduction_author,
      authorship:
    )
  end
end
