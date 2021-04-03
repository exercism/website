class UserTrack < ApplicationRecord
  extend Mandate::Memoize

  belongs_to :user
  belongs_to :track
  has_many :user_track_learnt_concepts, class_name: "UserTrack::LearntConcept", dependent: :destroy
  has_many :learnt_concepts, through: :user_track_learnt_concepts, source: :concept
  has_many :solutions,
    lambda { |ut|
      joins(:exercise).
        where("exercises.track_id": ut.track_id)
    },
    foreign_key: :user_id,
    primary_key: :user_id,
    inverse_of: :user_track

  before_create do
    self.summary_data = {}
  end

  def self.for!(user_param, track_param)
    UserTrack.find_by!(
      user: User.for!(user_param),
      track: Track.for!(track_param)
    )
  end

  def self.for(user_param, track_param, external_if_missing: false)
    for!(user_param, track_param)
  rescue ActiveRecord::RecordNotFound
    return nil unless external_if_missing

    begin
      External.new(Track.for!(track_param))
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

  def external?
    false
  end

  def completed_percentage
    c = (num_completed_exercises / num_exercises.to_f) * 100
    c.denominator == 1 ? c.round : c.round(1)
  end

  memoize
  def active_mentoring_discussions
    Mentor::Discussion.where(solution: solutions).in_progress
  end

  memoize
  def pending_mentoring_requests
    Mentor::Request.where(solution: solutions).pending
  end

  # TODO: Calculate and cache this somehow
  def num_locked_mentoring_slots
    1
  end

  # TODO: Extract 4 into a constant
  def num_available_mentoring_slots
    4 - num_used_mentoring_slots - num_locked_mentoring_slots
  end

  def num_used_mentoring_slots
    active_mentoring_discussions.size + pending_mentoring_requests.size
  end

  def tutorial_exercise_completed?
    num_completed_exercises.positive?
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
  end

  def reset_summary!
    reload
    @summary = nil
  end

  private
  # A track's summary is an efficiently created summary of all
  # of a user_track's data. It's cached across requests, allowing
  # us to quickly retrieve data without requiring lots of complex
  # SQL queries.
  def summary
    return @summary if @summary

    digest = Digest::SHA1.hexdigest(File.read(Rails.root.join('app', 'commands', 'user_track', 'generate_summary_data.rb')))
    expected_key = "#{track.updated_at.to_f}_#{updated_at.to_f}_#{digest}"

    if summary_key != expected_key
      update_columns(
        summary_key: expected_key,
        summary_data: UserTrack::GenerateSummaryData.(track, self)
      )
    end

    @summary = UserTrack::Summary.new(summary_data.with_indifferent_access)
  end
end
