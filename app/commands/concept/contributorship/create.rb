class Concept::Contributorship::Create
  include Mandate

  initialize_with :concept, :contributor

  def call
    begin
      contributorship = concept.contributorships.create!(contributor:)
    rescue ActiveRecord::RecordNotUnique
      return nil
    end

    User::ReputationToken::Create.defer(
      contributor,
      :concept_contribution,
      contributorship:
    )
  end
end
