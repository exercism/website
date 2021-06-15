class User::ReputationTokens::ConceptAuthorToken < User::ReputationToken
  params :authorship
  category :authoring
  reason :authored_concept
  value 10

  before_validation on: :create do
    self.track = authorship.concept.track unless track
    self.concept = authorship.concept unless concept
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
