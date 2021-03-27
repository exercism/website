class UserTrack < ApplicationRecord
  extend Mandate::Memoize

  belongs_to :user
  belongs_to :track
  has_many :user_track_learnt_concepts, class_name: "UserTrack::LearntConcept", dependent: :destroy
  has_many :learnt_concepts, through: :user_track_learnt_concepts, source: :concept

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

  def solutions
    user.solutions.joins(:exercise).where("exercises.track_id": track)
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

  delegate :exercise_unlocked?, :exercise_completed?, :exercise_status,
    :num_completed_exercises, :num_completed_concept_exercises, :num_completed_practice_exercises,
    :unlocked_exercise_ids, :avaliable_exercise_ids,
    :num_concepts, :num_concepts_learnt, :num_concepts_mastered,
    :num_exercises,
    :num_exercises_for_concept, :num_completed_exercises_for_concept,
    :concept_unlocked?, :concept_learnt?, :concept_mastered?,
    :concept_progressions, :unlocked_concept_ids,
    to: :summary

  memoize
  def unlocked_concept_exercises
    unlocked_exercises.select { |e| e.is_a?(ConceptExercise) }
  end

  memoize
  def unlocked_practice_exercises
    unlocked_exercises.select { |e| e.is_a?(PracticeExercise) }
  end

  memoize
  def unlocked_concepts
    Track::Concept.where(id: summary.unlocked_concept_ids)
  end

  memoize
  def mastered_concepts
    Track::Concept.where(id: summary.mastered_concept_ids)
  end

  memoize
  def unlocked_exercises
    Exercise.where(id: summary.unlocked_exercise_ids)
  end

  memoize
  def available_exercises
    Exercise.where(id: summary.available_exercise_ids)
  end

  memoize
  def in_progress_exercises
    Exercise.where(id: summary.in_progress_exercise_ids)
  end

  memoize
  def completed_exercises
    Exercise.where(id: summary.completed_exercises_ids)
  end

  private
  # A track's summary is a effeciently created summary of all
  # of a user_track's data. It's cached across requests, allowing
  # us to quickly retrieve data without requiring lots of complex
  # SQL queries.
  def summary
    @summary ||= UserTrack::GenerateSummary.(track, self)
  end
end
