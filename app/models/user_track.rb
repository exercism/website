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

  def exercise_available?(exercise)
    (exercise.prerequisites - learnt_concepts).empty?
  end

  memoize
  def available_concepts
    available_exercise_ids = available_exercises.map(&:id)
    concept_ids = Exercise::TaughtConcept.where(exercise_id: available_exercise_ids).
      select(:track_concept_id)

    track.concepts.not_taught + Track::Concept.where(id: concept_ids)
  end

  memoize
  def available_exercises
    without_prereqs = track.exercises.without_prerequisites

    return without_prereqs if learnt_concepts.blank?

    ids = DetermineAvailableExercisesIds.(id)
    without_prereqs + Exercise.where(id: ids)
  end

  ###
  # Inline helper for available exercises
  ###
  class DetermineAvailableExercisesIds
    include Mandate

    initialize_with :user_track_id

    # Get two datasets.
    # The second is the exercises with the count of all their prereq concepts
    # The second is the exercises with the count of all their prereq concepts
    # If the number is the same in both, then we have a match.
    #
    # Taken from https://stackoverflow.com/questions/48290118/sql-join-on-a-table-that-matches-multiple-rows-and-put-into-multiple-columns
    def call
      ActiveRecord::Base.connection.select_values(%{
        SELECT
          a.exercise_id
        FROM
          (
            SELECT prereqs.exercise_id, COUNT(*) AS num_concepts
            FROM user_track_learnt_concepts utc
            INNER JOIN exercise_prerequisites prereqs
              ON utc.track_concept_id = prereqs.track_concept_id
            INNER JOIN exercises on exercises.id = prereqs.exercise_id
            WHERE utc.user_track_id = #{user_track_id}
            GROUP BY prereqs.exercise_id
          ) a
        INNER JOIN
          (
            SELECT exercise_id, COUNT(*) AS num_concepts
            FROM exercise_prerequisites
            GROUP BY exercise_id
          ) b ON a.exercise_id = b.exercise_id AND a.num_concepts = b.num_concepts
     })
    end
  end
  private_constant :DetermineAvailableExercisesIds
end
