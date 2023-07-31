class SerializeIterations
  include Mandate

  initialize_with :iterations, comment_counts: nil, sideload: []

  def call
    eager_loaded_iterations.map do |iteration|
      SerializeIteration.(iteration, sideload:).tap do |serialized|
        if comment_counts
          counts = comment_counts.select { |(it_id, _), _| it_id == iteration.id }
          unread = counts.reject { |(_, seen), _| seen }.present?

          serialized[:unread] = unread
        end
      end
    end
  end

  def eager_loaded_iterations
    # We don't need eager loading if we have an array
    # with zero or one iterations in.
    return iterations if iterations.size < 2

    its = iterations.includes(
      :exercise,
      :track,
      solution: :latest_iteration,
      submission: %i[
        analysis
        submission_representation
        exercise_representation
        solution
      ]
    )
    its = its.includes(:files) if sideload.include?(:files)
    its
  end
end
