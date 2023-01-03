class UserTrack::GenerateConceptStatusMapping
  include Mandate

  initialize_with :user_track

  def call
    return {} if user_track.external?

    {}.tap do |output|
      set_status = ->(slugs, status) { slugs.each { |slug| output[slug] = status } }

      set_status.(user_track.concept_slugs, :locked)
      set_status.(user_track.unlocked_concept_slugs, :available)
      set_status.(user_track.learnt_concept_slugs, :learnt)
      set_status.(user_track.mastered_concept_slugs, :mastered)
    end
  end
end
