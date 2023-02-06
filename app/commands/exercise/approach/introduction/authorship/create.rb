class Exercise::Approach::Introduction::Authorship::Create
  include Mandate

  initialize_with :exercise, :author

  def call
    exercise.approach_introduction_authorships.find_create_or_find_by!(author:).tap do |authorship|
      User::ReputationToken::Create.defer(author, :exercise_approach_introduction_author, authorship:)
    end
  end
end
