class User::ReputationTokens::ConceptContributionToken < User::ReputationToken
  params :contributorship
  category :authoring
  reason :contributed_to_concept
  value 5

  before_validation on: :create do
    self.track = contributorship.concept.track unless track
    self.concept = contributorship.concept unless concept
    self.earned_on = concept.created_at unless earned_on
  end

  def i18n_params
    {
      concept_title: concept.title
    }
  end

  def guard_params
    "Concept##{concept.id}"
  end
end
