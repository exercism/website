class Concept::Authorship::Create
  include Mandate

  initialize_with :concept, :author

  def call
    begin
      authorship = concept.authorships.create!(author:)
    rescue ActiveRecord::RecordNotUnique
      return nil
    end

    User::ReputationToken::Create.defer(
      author,
      :concept_author,
      authorship:
    )
  end
end
