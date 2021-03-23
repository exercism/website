class UserTrack
  class GenerateExerciseStatusMapping
    include Mandate

    initialize_with :track, :user_track

    def call
      concept_slugs = track.concepts.pluck(:slug)
      concept_slugs.each.with_object({}) do |slug, hash|
        hash[slug] = mapping[slug]
      end
    end

    private
    memoize
    def mapping
      mapping = Hash.new { |k, v| k[v] = Set.new }

      Exercise::TaughtConcept.joins(:exercise, :concept).
        where('exercises.track_id': track.id).
        pluck("track_concepts.slug", "exercises.slug").
        each do |concept_slug, exercise_slug|
        next if concept_slug.nil?
        next if exercise_slug.nil?

        mapping[concept_slug] << exercise_slug
      end

      # TOOD: Change to practice link and remove limit
      Exercise::Prerequisite.joins(:exercise, :concept).
        where('exercises.track_id': track.id).
        limit(7).
        pluck("track_concepts.slug", "exercises.slug").
        each do |concept_slug, exercise_slug|
        next if concept_slug.nil?
        next if exercise_slug.nil?

        mapping[concept_slug] << exercise_slug
      end

      mapping.transform_values do |exercise_slugs|
        exercise_slugs.map do |slug|
          user_track.external? ? "available" : user_track.exercise_status(slug)
        end
      end
    end
  end
end
