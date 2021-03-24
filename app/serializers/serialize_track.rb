class SerializeTrack
  include Mandate

  def initialize(track, user_track,
                 num_concepts: nil,
                 num_learnt_concepts: nil,
                 num_concept_exercises: nil,
                 num_practice_exercises: nil,
                 num_completed_concept_exercises: nil,
                 num_completed_practice_exercises: nil)

    @track = track
    @user_track = user_track
    @num_concepts = num_concepts
    @num_learnt_concepts = num_learnt_concepts
    @num_concept_exercises = num_concept_exercises
    @num_practice_exercises = num_practice_exercises
    @num_completed_concept_exercises = num_completed_concept_exercises
    @num_completed_practice_exercises = num_completed_practice_exercises
  end

  def call
    {
      id: track.slug,
      title: track.title,
      num_concepts: num_concepts,
      num_concept_exercises: num_concept_exercises,
      num_practice_exercises: num_practice_exercises,
      web_url: Exercism::Routes.track_url(track),
      icon_url: track.icon_url,

      # TODO: Set all three of these
      is_new: true,
      tags: map_tags(track.tags),
      updated_at: track.updated_at.iso8601
    }.merge(user_data_for_track)
  end

  private
  attr_reader :track, :user_track

  def map_tags(tags)
    tags.to_a.map do |tag|
      Track::TAGS.dig(*tag.split('/'))
    rescue StandardError
      nil
    end.compact
  end

  def user_data_for_track
    return {} if !user_track || user_track.external?

    {
      is_joined: joined?,
      num_learnt_concepts: num_learnt_concepts,
      num_completed_concept_exercises: num_completed_concept_exercises,
      num_completed_practice_exercises: num_completed_practice_exercises
    }
  end

  def num_concepts
    return @num_concepts unless @num_concepts.nil?

    track.concepts.count
  end

  def num_learnt_concepts
    return @num_learnt_concepts unless @num_learnt_concepts.nil?
    return 0 unless joined?

    user_track.num_concepts_learnt
  end

  def num_concept_exercises
    return @num_concept_exercises unless @num_concept_exercises.nil?

    track.concept_exercises.count
  end

  def num_practice_exercises
    return @num_practice_exercises unless @num_practice_exercises.nil?

    track.practice_exercises.count
  end

  def num_completed_concept_exercises
    return @num_completed_concept_exercises unless @num_completed_concept_exercises.nil?
    return 0 unless joined?

    user_track.num_completed_concept_exercises
  end

  def num_completed_practice_exercises
    return @num_completed_practice_exercises unless @num_completed_practice_exercises.nil?
    return 0 unless joined?

    user_track.num_completed_practice_exercises
  end

  memoize
  def joined?
    !!user_track
  end
end
