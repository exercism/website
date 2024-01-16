class Solution::UpdatePublishedExerciseRepresentation
  include Mandate

  initialize_with :solution

  def call
    old_representation = solution.published_exercise_representation
    new_representation = solution.latest_published_iteration_submission&.exercise_representation

    # If they're the same, don't waste the cycles
    # This shouldn't really happen though
    return if old_representation == new_representation

    solution.update!(published_exercise_representation: new_representation)

    # This is commonly called within transactions, so give it 30secs to update
    Exercise::Representation::Recache.defer(old_representation, wait: 30.seconds) if old_representation
    Exercise::Representation::Recache.defer(new_representation, wait: 30.seconds) if new_representation
  end
end
