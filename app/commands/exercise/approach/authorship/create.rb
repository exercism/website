class Exercise::Approach::Authorship::Create
  include Mandate

  initialize_with :approach, :author

  def call
    approach.authorships.find_create_or_find_by!(author:).tap do |authorship|
      User::ReputationToken::Create.defer(author, :exercise_approach_author, authorship:)
    end
  end
end
