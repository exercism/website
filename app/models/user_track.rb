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
    42.5
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

  delegate :exercise_unlocked?, :exercise_completed?, :exercise_status, :exercise_short_status,
    :num_completed_exercises, :num_completed_concept_exercises, :num_completed_practice_exercises,
    :unlocked_exercise_ids, :avaliable_exercise_ids,
    :num_concepts, :num_concepts_learnt, :num_concepts_mastered,
    :num_exercises,
    :num_exercises_for_concept, :num_completed_exercises_for_concept,
    :concept_unlocked?, :concept_learnt?, :concept_mastered?,
    :concept_progressions, :concept_slugs,
    :unlocked_concept_ids, :unlocked_concept_slugs,
    :learnt_concept_ids, :learnt_concept_slugs,
    :mastered_concept_ids, :mastered_concept_slugs,
    :unlocked_concepts, :mastered_concepts,
    :unlocked_concept_exercises, :unlocked_practice_exercises,
    :unlocked_exercises, :available_exercises, :in_progress_exercises, :completed_exercises,
    to: :summary

  def reset_summary!
    self.update_column(:summary_key, nil)
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
    expected_key = "#{track.updated_at.to_i}_#{updated_at.to_i}_#{digest}"

    if summary_key != expected_key
      update_columns(
        summary_key: expected_key,
        summary_data: UserTrack::GenerateSummaryData.(track, self)
      )
    end

    @summary = UserTrack::Summary.new(summary_data.with_indifferent_access)
  end
end
