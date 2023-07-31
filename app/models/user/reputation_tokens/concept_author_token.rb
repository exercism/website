class User::ReputationTokens::ConceptAuthorToken < User::ReputationToken
  params :authorship, :concept
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
      concept_name: concept.name
    }
  end

  def guard_params = "Concept##{concept.id}"

  def internal_url
    Exercism::Routes.track_concept_path(track, concept)
  end
end
