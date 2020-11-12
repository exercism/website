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

  def self.for(user_param, track_param)
    for!(user_param, track_param)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def solutions
    user.solutions.joins(:exercise).where("exercises.track_id": track)
  end

  # A track's summary is a effeciently created summary of all
  # of a user_track's data. It's cached across requests, allowing
  # us to quickly retrieve data without requiring lots of complex
  # SQL queries. There is a little bit of a dance here, which is
  # documented in the UserTrack::GenerateSummary class.
  attr_writer :summary
  def summary
    @summary ||= UserTrack::GenerateSummary.(track, self)
  end

  def summary_generated?
    !!@summary
  end

  delegate :exercise_available?, :concept_available?, to: :summary

  def learnt_concept?(concept)
    learnt_concepts.include?(concept)
  end

  def concept_available?(concept)
    available_concepts.include?(concept)
  end

  memoize
  def available_concept_exercises
    available_exercises.select { |e| e.is_a?(ConceptExercise) }
  end

  memoize
  def available_practice_exercises
    available_exercises.select { |e| e.is_a?(PracticeExercise) }
  end

  memoize
  def available_concepts
    Track::Concept.where(id: summary.available_concept_ids)
  end

  memoize
  def available_exercises
    Exercise.where(id: summary.available_exercise_ids)
  end
end
