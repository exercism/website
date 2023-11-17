class Exercise::Authorship::Create
  include Mandate

  initialize_with :exercise, :author

  def call
    exercise.authorships.find_create_or_find_by!(author:).tap do |authorship|
      User::ReputationToken::Create.defer(
        author,
        :exercise_author,
        authorship:,
        # This is called in a big transaction, so give it time
        # to materialise to the database before calling things.
        wait: 30.seconds
      )
    end
  end
end
