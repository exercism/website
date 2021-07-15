class UserTrack < ApplicationRecord
  extend Mandate::Memoize
  include UserTrack::MentoringSlots

  serialize :summary_data, JSON

  belongs_to :user
  belongs_to :track
  has_many :solutions,
    lambda { |ut|
      joins(:exercise).
        where("exercises.track_id": ut.track_id)
    },
    foreign_key: :user_id,
    primary_key: :user_id,
    inverse_of: :user_track

  before_create do
    self.last_touched_at = Time.current unless self.last_touched_at
    self.summary_data = {}
  end

  # Add some caching inside here for the duration
  # of the request cycle.
  def self.for!(user_param, track_param)
    UserTrack.find_by!(
      user: User.for!(user_param),
      track: Track.for!(track_param)
    )
  end

  def self.for(user_param, track_param)
    for!(user_param, track_param)
  rescue ActiveRecord::RecordNotFound
    begin
      External.new(Track.for!(track_param))
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

  memoize
  def exercises
    filter_enabled_exercises(track.exercises)
  end

  memoize
  def concept_exercises
    filter_enabled_exercises(track.concept_exercises)
  end

  memoize
  def practice_exercises
    filter_enabled_exercises(track.practice_exercises)
  end

  def concept_exercises_for(concept: nil)
    filter_enabled_exercises(concept.concept_exercises) if concept.present?
  end

  def practice_exercises_for(concept: nil)
    filter_enabled_exercises(concept.practice_exercises) if concept.present?
  end

  def unlocked_concepts_for(exercise: nil)
    exercise.unlocked_concepts.to_a.filter { |c| concept_unlocked?(c) } if exercise.present?
  end

  def unlocked_exercises_for(exercise: nil)
    exercise.unlocked_exercises.to_a.filter { |e| exercise_unlocked?(e) } if exercise.present?
  end

  def external?
    false
  end

  memoize
  def has_notifications?
    User::Notification.unread.
      where(user_id: user_id, track_id: track_id).
      exists?
  end

  def completed_percentage
    c = (num_completed_exercises / num_exercises.to_f) * 100
    c.denominator == 1 ? c.round : c.round(1)
  end

  memoize
  def active_mentoring_discussions
    Mentor::Discussion.where(solution: solutions).in_progress_for_student
  end

  memoize
  def pending_mentoring_requests
    Mentor::Request.where(solution: solutions).pending
  end

  def tutorial_exercise_completed?
    num_completed_exercises.positive?
  end

  def exercise_has_notifications?(exercise)
    # None of these can have notifications
    # so avoid the expense of a db call
    return false if %i[
      locked available started
    ].include?(exercise_status(exercise))

    User::Notification.unread.
      where(user_id: user_id, exercise_id: exercise.id).
      exists?
  end

  # In Ruby 2.7 and Ruby 3 we'll need **kwargs here.
  def method_missing(meth, *args, &block)
    summary.public_send(meth, *args, &block)
  end

  def respond_to_missing?(meth, include_all)
    return false if %i[
      to_ary
    ].include?(meth)

    summary.respond_to?(meth, include_all)
  rescue StandardError
    true # We need this for test-mocking. It's messy.
  end

  def reset_summary!
    reload
    self.summary_key = nil
    @summary = nil
  end

  private
  def filter_enabled_exercises(exercises)
    exercises.where(status: %i[active beta]).or(exercises.where(id: solutions.select(:exercise_id)))
  end

  # A track's summary is an efficiently created summary of all
  # of a user_track's data. It's cached across requests, allowing
  # us to quickly retrieve data without requiring lots of complex
  # SQL queries.
  def summary
    return @summary if @summary

    digest = Digest::SHA1.hexdigest(File.read(Rails.root.join('app', 'commands', 'user_track', 'generate_summary_data.rb')))
    track_updated_at = association(:track).loaded? ? track.updated_at : Track.where(id: track_id).pick(:updated_at)
    expected_key = "#{track_updated_at.to_f}:#{updated_at.to_f}:#{digest}"

    if summary_key != expected_key
      # It is important to use update_columns here
      # else we'll touch updated_at and end up always
      # invalidating the cache immediately.
      update_columns(
        summary_key: expected_key,
        summary_data: UserTrack::GenerateSummaryData.(track, self)
      )
    end

    @summary = UserTrack::Summary.new(summary_data.with_indifferent_access)
  end
end
