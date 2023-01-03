class Exercise::Authorship::Create
  include Mandate

  initialize_with :exercise, :author

  def call
    begin
      authorship = exercise.authorships.create!(author:)
    rescue ActiveRecord::RecordNotUnique
      return nil
    end

    User::ReputationToken::Create.defer(
      author,
      :exercise_author,
      authorship:
    )
  end
end
