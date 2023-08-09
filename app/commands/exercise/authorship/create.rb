class Exercise::Authorship::Create
  include Mandate

  initialize_with :exercise, :author

  def call
    exercise.authorships.find_or_create_by(author:).tap do |authorship|
      User::ReputationToken::Create.defer(
        author,
        :exercise_author,
        authorship:
      )
    end
  end
end
