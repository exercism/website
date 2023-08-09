class Concept::Authorship::Create
  include Mandate

  initialize_with :concept, :author

  def call
    concept.authorships.find_or_create_by(author:).tap do |authorship|
      User::ReputationToken::Create.defer(
        author,
        :concept_author,
        authorship:
      )
    end
  end
end
