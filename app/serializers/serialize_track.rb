class SerializeTrack
  include Mandate

  def initialize(track, user_track, has_notifications: nil)
    @track = track
    @user_track = user_track || UserTrack::External.new(track)
    @has_notifications = has_notifications
  end

  def call
    {
      slug: track.slug,
      title: track.title,
      course: track.course?,
      num_concepts: user_track.num_concepts,
      num_exercises: user_track.num_exercises,
      web_url: Exercism::Routes.track_url(track),
      icon_url: track.icon_url,
      tags: map_tags(track.tags),
      last_touched_at: user_track.last_touched_at&.iso8601,
      is_new: track.created_at > Time.current - 6.months,
      links: {
        self: Exercism::Routes.track_url(track),
        exercises: Exercism::Routes.track_exercises_url(track),
        concepts: Exercism::Routes.track_concepts_url(track)
      }
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
    return {} if user_track.external?

    {
      is_joined: true,
      num_learnt_concepts: user_track.num_concepts_learnt,
      num_completed_exercises: user_track.num_completed_exercises,
      num_solutions: 2, # TODO
      has_notifications: has_notifications?
    }
  end

  def has_notifications?
    return @has_notifications unless @has_notifications.nil?

    user_track.has_notifications?
  end
end
