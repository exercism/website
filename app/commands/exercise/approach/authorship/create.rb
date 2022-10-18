class Exercise::Approach::Authorship::Create
  include Mandate

  initialize_with :approach, :author

  def call
    begin
      authorship = approach.authorships.create!(author:)
    rescue ActiveRecord::RecordNotUnique
      return nil
    end

    User::ReputationToken::Create.defer(author, :exercise_approach_author, authorship:)
  end
end
