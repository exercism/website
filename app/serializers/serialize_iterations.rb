class SerializeIterations
  include Mandate

  initialize_with :iterations, sideload: []

  def call
    eager_loaded_iterations.map do |iteration|
      SerializeIteration.(iteration, sideload:)
    end
  end

  def eager_loaded_iterations
    # We don't need eager loading if we have an array
    # with zero or one iterations in.
    return iterations if iterations.size < 2

    iterations.includes(
      :exercise,
      :track,
      submission: %i[
        solution analysis submission_representation
      ]
    )
  end
end
