class Track::UpdateTags
  include Mandate

  initialize_with :track

  def call = track.update(analyzer_tags:)

  private
  def analyzer_tags
    existing_tags = track.analyzer_tags.where(tag: exercise_tags).select(:id, :tag).to_a
    track_tags = existing_tags.map(&:tag)

    new_tags = (exercise_tags - track_tags).map do |tag|
      Track::Tag.find_create_or_find_by!(tag:, track:)
    end

    existing_tags + new_tags
  end

  memoize
  def exercise_tags = Exercise::Tag.where(exercise_id: track.exercises.select(:id)).distinct.pluck(:tag)
end
