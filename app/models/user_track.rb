class UserTrack < ApplicationRecord
  belongs_to :user
  belongs_to :track
  has_many :user_track_concepts, class_name: "UserTrack::Concept"
  has_many :learnt_concepts, through: :user_track_concepts, source: :track_concept

  def self.for!(user_param, track_param)
    UserTrack.find_by!(
      user: User.for!(user_param),
      track: Track.for!(track_param)
    )
  end

  def available_concept_exercises
    available_exercises.select{|e|e.is_a?(ConceptExercise)}
  end

  def available_practice_exercises
    available_exercises.select{|e|e.is_a?(PracticeExercise)}
  end

  #TODO: Memoize this
  def available_exercises
    without_prereqs = track.exercises.without_prerequisites

    return without_prereqs unless learnt_concepts.present?

    ids = DetermineAvailableExercisesIds.(id)
    without_prereqs + Exercise.where(id: ids)
  end

  def exercise_available?(exercise)
    (exercise.prerequisites - learnt_concepts).size == 0
  end

  ### 
  # Inline helper for available concept Exercises
  ###
  class DetermineAvailableExercisesIds
    include Mandate

    initialize_with :user_track_id

    # Get two datasets. 
    # The first is the exercises with their counts of MATCHING preqreq concepts
    # The second is the execises with the count of all their preqreq concepts
    # If the number is the same in both, then we have a match.
    #
    # Taken from https://stackoverflow.com/questions/48290118/sql-join-on-a-table-that-matches-multiple-rows-and-put-into-multiple-columns
    def call
      ActiveRecord::Base.connection.select_values(%Q{
        SELECT
          a.exercise_id
        FROM
          (
            SELECT prereqs.exercise_id, COUNT(*) AS num_concepts
            FROM user_track_concepts utc
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
