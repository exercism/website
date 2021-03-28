class UserTrack
  class GenerateConceptStatusMapping
    include Mandate

    initialize_with :user_track

    def call
      return {} unless user_track && !user_track.external?

      all_concepts = user_track.concept_slugs
      unlocked_concepts = user_track.unlocked_concept_slugs
      learnt_concepts = user_track.learnt_concept_slugs

      {}.tap do |output|
        set_status = ->(slugs, status) { slugs.each { |slug| output[slug] = status } }

        set_status.(all_concepts, :locked)
        set_status.(unlocked_concepts, :available)
        set_status.(learnt_concepts, :complete)
      end
    end
  end
end
