class Concept::Contributorship::Create
  include Mandate

  initialize_with :concept, :contributor

  def call
    concept.contributorships.find_or_create_by(contributor:).tap do |contributorship|
      User::ReputationToken::Create.defer(
        contributor,
        :concept_contribution,
        contributorship:
      )
    end
  end
end
